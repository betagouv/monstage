# frozen_string_literal: true

require "sti_preload"
class InternshipOffer < ApplicationRecord
  include StiPreload
  PAGE_SIZE = 30
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250
  MAX_CANDIDATES_HIGHEST = 200
  TITLE_MAX_CHAR_COUNT = 150
  DESCRIPTION_MAX_CHAR_COUNT= 500

  # queries
  include Listable
  include FindableWeek
  include Zipcodable

  include StepperProxy::InternshipOfferInfo
  include StepperProxy::Organisation
  include StepperProxy::Tutor

  # utils
  include Discard::Model
  include PgSearch::Model

  # public.config_search_keyword config is
  # this TEXT SEARCH CONFIGURATION is based on 2 keys concepts
  #   unaccent : which tokenize content without accent [search is also applied without accent]
  # .  french stem : which tokenize content for french FT
  # plus some customization to ignores
  #   email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
  pg_search_scope :search_by_keyword,
                  against: {
                    title: 'A',
                    description: 'B',
                    employer_description: 'C'
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'public.config_search_keyword',
                      tsvector_column: 'search_tsv',
                      prefix: true
                    }
                  }

  scope :by_sector, lambda { |sector_id|
    where(sector_id: sector_id)
  }

  scope :with_seats, lambda {
    where('remaining_seats_count > 0')
  }

  scope :limited_to_department, lambda { |user:|
    where(department: user.department)
  }

  scope :limited_to_ministry, lambda { |user:|
    return none if user.ministries.empty?

    where(group_id: user.ministries.map(&:id))
  }

  scope :from_api, lambda {
    where.not(permalink: nil)
  }

  scope :not_from_api, lambda {
    where(permalink: nil)
  }

  scope :ignore_internship_restricted_to_other_schools, lambda { |school_id:|
    where(school_id: [nil, school_id])
  }

  scope :in_the_future, lambda {
    where('last_date > :now', now: Time.now)
  }

  scope :ignore_max_candidates_reached, lambda {
    all # TODO : max_candidates specs for FreeDate required
  }

  scope :unpublished, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

  scope :weekly_framed, lambda {
    where(type: [InternshipOffers.name,
                 InternshipOffers::Api.name])
  }

  scope :ignore_already_applied, lambda { |user:|
    where.not(id: InternshipApplication.where(user_id: user.id).map(&:internship_offer_id))
  }

  # scope :ignore_already_applied, lambda { |user:|
  #   where(type: ['InternshipOffers', 'InternshipOffers::Api'])
  #     .where.not(id: InternshipApplication.where(user_id: user.id).map(&:internship_offer_id))
  # }

  scope :fulfilled, lambda {
    applications_ar = InternshipApplication.arel_table
    offers_ar       = InternshipOffer.arel_table

    joins(internship_offer_weeks: :internship_applications)
      .where(applications_ar[:aasm_state].in(%w[approved signed]))
      .select([offers_ar[:id], applications_ar[:id].count.as('applications_count'), offers_ar[:max_candidates], offers_ar[:max_students_per_group]])
      .group(offers_ar[:id])
      .having(applications_ar[:id].count.gteq(offers_ar[:max_candidates]))
  }

  scope :uncompleted, lambda {
    offers_ar       = InternshipOffer.arel_table
    full_offers_ids = InternshipOffers.fulfilled.pluck(:id)

    where(offers_ar[:id].not_in(full_offers_ids))
  }

  # Retourner toutes les offres qui ont au moins une semaine de libre ???
  scope :ignore_max_candidates_reached, lambda { 
    offer_weeks_ar = InternshipOfferWeek.arel_table
    offers_ar      = InternshipOffer.arel_table

    joins(:internship_offer_weeks)
      .select(offers_ar[Arel.star], offers_ar[:id].count)
      .left_joins(:internship_applications)
      .where(offer_weeks_ar[:blocked_applications_count].lt(offers_ar[:max_students_per_group]))
      .where(offers_ar[:id].not_in(InternshipOffers.fulfilled.pluck(:id)))
      .group(offers_ar[:id])
  }

  
  # scope :ignore_max_internship_offer_weeks_reached, lambda {
  #   where('internship_offer_weeks_count > blocked_weeks_count')
  # }

  scope :specific_school_year, lambda { |school_year:|
    week_ids = Week.weeks_of_school_year(school_year: school_year).pluck(:id)

    joins(:internship_offer_weeks)
      .where('internship_offer_weeks.week_id in (?)', week_ids)
  }

  #---------------------
  # fullfilled scope isolates those offers that have reached max_candidates
  #---------------------
  scope :fulfilled, lambda {
    offers_ar      = InternshipOffer.arel_table
    offer_weeks_ar = InternshipOfferWeek.arel_table

    joins(:internship_offer_weeks)
      .select([offer_weeks_ar[:blocked_applications_count].sum, offers_ar[:id],offers_ar[:max_candidates]])
      .group(offers_ar[:id])
      .having(offer_weeks_ar[:blocked_applications_count].sum.gteq(offers_ar[:max_candidates]))
  }

  scope :uncompleted_with_max_candidates, lambda {
    offers_ar       = InternshipOffer.arel_table
    full_offers_ids = InternshipOffer.fulfilled.ids

    where(offers_ar[:id].not_in(full_offers_ids))
  }

  has_many :internship_applications, as: :internship_offer,
                                     foreign_key: 'internship_offer_id'
  has_many :internship_offer_weeks, dependent: :destroy,
                                     foreign_key: :internship_offer_id,
                                     inverse_of: :internship_offer 
  has_many :weeks, through: :internship_offer_weeks

  belongs_to :employer, polymorphic: true
  belongs_to :organisation, optional: true
  belongs_to :tutor, optional: true
  belongs_to :internship_offer_info, optional: true
  has_many :favorites
  has_many :users, through: :favorites

  has_rich_text :employer_description_rich_text

  after_initialize :init

  before_save :sync_first_and_last_date,
              :reverse_academy_by_zipcode

  before_create :preset_published_at_to_now
  after_commit :sync_internship_offer_keywords

  scope :published, -> { where.not(published_at: nil) }

  paginates_per PAGE_SIZE

  delegate :email, to: :employer, prefix: true, allow_nil: true
  delegate :phone, to: :employer, prefix: true, allow_nil: true
  delegate :name, to: :sector, prefix: true

  # Callbacks
  before_save :update_remaining_seats

  # Validations
  validates :weeks, presence: true


  def weeks_count
    internship_offer_weeks.count
  end

  def first_monday
    I18n.l internship_offer_weeks.first.week.week_date,
           format: Week::WEEK_DATE_FORMAT
  end

  def last_monday
    I18n.l internship_offer_weeks.last.week.week_date,
           format: Week::WEEK_DATE_FORMAT
  end

  def has_spots_left?
    internship_offer_weeks.any?(&:has_spots_left?)
  end

  def is_fully_editable?
    internship_applications.empty?
  end

  #
  # callbacks
  #
  def sync_first_and_last_date
    ordered_weeks = weeks.sort { |a, b| [a.year, a.number] <=> [b.year, b.number] }
    first_week = ordered_weeks.first
    last_week = ordered_weeks.last
    self.first_date = first_week.week_date.beginning_of_week
    self.last_date = last_week.week_date.end_of_week
  end

  #
  # inherited
  #
  def duplicate
    internship_offer = super
    internship_offer.week_ids = week_ids
    internship_offer
  end

  def departement
    Department.lookup_by_zipcode(zipcode: zipcode)
  end

  def operator
    return nil if !from_api?
    employer.operator
  end

  def published?
    published_at.present?
  end

  def from_api?
    permalink.present?
  end

  def reserved_to_school?
    school.present?
  end

  def is_fully_editable?
    true
  end

  def init
    self.max_candidates ||= 1
  end

  def already_applied_by_student?(student)
    !!internship_applications.where(user_id: student.id).first
  end

  def total_no_gender_applications_count
    total_applications_count - total_male_applications_count - total_female_applications_count
  end

  # def total_no_gender_convention_signed_applications_count
  #   convention_signed_applications_count - total_male_convention_signed_applications_count - total_female_convention_signed_applications_count
  # end

  def anonymize
    fields_to_reset = {
      tutor_name: 'NA',
      tutor_phone: 'NA',
      tutor_email: 'NA',
      tutor_role: 'NA',
      title: 'NA',
      description: 'NA',
      employer_website: 'NA',
      street: 'NA',
      employer_name: 'NA',
      employer_description: 'NA'
    }
    update(fields_to_reset)
    discard
  end

  def duplicate
    white_list = %w[type title sector_id max_candidates max_students_per_group
                    tutor_name tutor_phone tutor_email tutor_role employer_website
                    employer_name street zipcode city department region academy
                    is_public group school_id coordinates first_date last_date
                    siret employer_manual_enter
                    internship_offer_info_id organisation_id tutor_id
                    weekly_hours new_daily_hours]

    generate_offer_from_attributes(white_list)
  end

  def duplicate_without_location
    white_list_without_location = %w[type title sector_id max_candidates
                    tutor_name tutor_phone tutor_email tutor_role employer_website
                    employer_name is_public group school_id coordinates
                    first_date last_date siret employer_manual_enter
                    internship_offer_info_id organisation_id tutor_id
                    weekly_hours new_daily_hours]

    generate_offer_from_attributes(white_list_without_location)
  end

  def generate_offer_from_attributes(white_list)
    internship_offer = InternshipOffer.new(attributes.slice(*white_list))
    internship_offer.description_rich_text = (if description_rich_text.present?
                                                description_rich_text.to_s
                                              else
                                                description
                                              end)
    internship_offer.employer_description_rich_text = (if employer_description_rich_text.present?
                                                         employer_description_rich_text.to_s
                                                       else
                                                         employer_description
                                                       end)
    internship_offer
  end

  def preset_published_at_to_now
    self.published_at = Time.now
  end

  def reverse_academy_by_zipcode
    self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
  end

  def sync_internship_offer_keywords
    previous_title, new_title = title_previous_change
    previous_description, new_description = description_previous_change
    previous_employer_description, new_employer_description = employer_description_previous_change

    if [previous_title != new_title,
        previous_description != new_description,
        previous_employer_description != new_employer_description].any?
      SyncInternshipOfferKeywordsJob.perform_later
    end
  end

  def with_applications?
    self.internship_applications.count.positive?
  end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end

  def presenter
    Presenters::InternshipOffer.new(self)
  end

  def update_all_favorites
    if approved_applications_count >= max_candidates || Time.now > last_date
      Favorite.where(internship_offer_id: id).destroy_all 
    end
  end

  def update_remaining_seats
    reserved_places = internship_offer_weeks
                        .where('internship_offer_weeks.blocked_applications_count > 0')
                        .count
    self.remaining_seats_count = max_candidates - reserved_places
  end
end
