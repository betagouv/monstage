# frozen_string_literal: true

require "sti_preload"
class InternshipOffer < ApplicationRecord
  PAGE_SIZE = 30
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250
  MAX_CANDIDATES_HIGHEST = 200
  TITLE_MAX_CHAR_COUNT = 150
  DESCRIPTION_MAX_CHAR_COUNT= 500

  include StiPreload
  include AASM

  # queries
  include Listable
  include FindableWeek
  include Zipcodable

  include StepperProxy::InternshipOfferInfo
  include StepperProxy::Organisation
  include StepperProxy::HostingInfo
  include StepperProxy::PracticalInfo

  # utils
  include Discard::Model
  include PgSearch::Model

  attr_accessor :republish

  # Other associations

  has_many :internship_applications, as: :internship_offer,
                                     foreign_key: 'internship_offer_id'

  belongs_to :organisation, optional: true
  belongs_to :internship_offer_info, optional: true
  belongs_to :hosting_info, optional: true
  belongs_to :practical_info, optional: true
  belongs_to :employer, polymorphic: true, optional: true
  belongs_to :internship_offer_area, optional: true, touch: true
  has_many :favorites
  has_many :users, through: :favorites
  has_many :users_internship_offers_histories, dependent: :destroy
  has_many :internship_offer_weeks, dependent: :destroy,
                                    foreign_key: :internship_offer_id,
                                    inverse_of: :internship_offer
  has_many :weeks, through: :internship_offer_weeks
  has_one :stats, class_name: 'InternshipOfferStats', dependent: :destroy

  accepts_nested_attributes_for :organisation, allow_destroy: true

  has_rich_text :employer_description_rich_text

   # Callbacks
  after_initialize :init

  before_validation :update_organisation

  before_save :sync_first_and_last_date,
              :reverse_academy_by_zipcode,
              :make_sure_area_is_set

  before_create :preset_published_at_to_now
  after_commit :sync_internship_offer_keywords
  after_create :create_stats
  after_update :update_stats

  paginates_per PAGE_SIZE

  # Délegate
  delegate :email, to: :employer, prefix: true, allow_nil: true
  delegate :phone, to: :employer, prefix: true, allow_nil: true
  delegate :name, to: :sector, prefix: true
  delegate :remaining_seats_count, to: :stats, allow_nil: true
  delegate :blocked_weeks_count, to: :stats, allow_nil: true
  delegate :total_applications_count, to: :stats, allow_nil: true
  delegate :approved_applications_count, to: :stats, allow_nil: true
  delegate :submitted_applications_count, to: :stats, allow_nil: true
  delegate :rejected_applications_count, to: :stats, allow_nil: true
  delegate :view_count, to: :stats, allow_nil: true
  delegate :total_male_applications_count, to: :stats, allow_nil: true
  delegate :total_female_applications_count, to: :stats, allow_nil: true
  delegate :total_male_approved_applications_count, to: :stats, allow_nil: true
  delegate :total_female_approved_applications_count, to: :stats, allow_nil: true
  delegate :update_need, to: :stats, allow_nil: true

  # Validations
  validates :contact_phone,
    presence: true,
    unless: :from_api?,
    length: { minimum: 10 },
    on: :create
  validates :contact_phone,
    unless: :from_api?,
    format: { with: /\A\+?[\d\s]+\z/,
              message: 'Le numéro de téléphone doit contenir des caractères chiffrés uniquement' },
    on: :create

  validates :weeks, presence: true
  validate :check_missing_seats_or_weeks, if: :user_update?, on: :update

  # Scopes

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
    joins(:stats).where('internship_offer_stats.remaining_seats_count > 0')
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

  scope :filter_when_max_candidtes_reached, lambda {
    all
  }

  scope :weekly_framed, lambda {
    where(type: [InternshipOffers::WeeklyFramed.name,
                 InternshipOffers::Api.name])
  }

  scope :ignore_already_applied, lambda { |user:|
    where.not(id: InternshipApplication.where(user_id: user.id).map(&:internship_offer_id))
  }

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
    full_offers_ids = InternshipOffers::WeeklyFramed.fulfilled.pluck(:id)

    where(offers_ar[:id].not_in(full_offers_ids))
  }

  # Retourner toutes les offres qui ont au moins une semaine de libre ???
  scope :filter_when_max_candidtes_reached, lambda {
    offer_weeks_ar = InternshipOfferWeek.arel_table
    offers_ar      = InternshipOffer.arel_table

    joins(:internship_offer_weeks)
      .select(offers_ar[Arel.star], offers_ar[:id].count)
      .left_joins(:internship_applications)
      .where(offer_weeks_ar[:blocked_applications_count].lt(offers_ar[:max_students_per_group]))
      .where(offers_ar[:id].not_in(InternshipOffers::WeeklyFramed.fulfilled.pluck(:id)))
      .group(offers_ar[:id])
  }

  scope :specific_school_year, lambda { |school_year:|
    week_ids = Week.weeks_of_school_year(school_year: school_year).pluck(:id)

    joins(:internship_offer_weeks)
      .where('internship_offer_weeks.week_id in (?)', week_ids)
  }

  scope :shown_to_employer, lambda {
    where(hidden_duplicate: false)
  }

  scope :with_weeks_next_year, lambda {
    joins(:internship_offer_weeks).where(
      internship_offer_weeks: { week_id:  Week.selectable_on_next_school_year }
    ).distinct
  }

  aasm do
    state :drafted, initial: true
    state :published,
          :removed,
          :unpublished,
          :need_to_be_updated,
          :splitted

    event :publish do
      transitions from: %i[drafted unpublished need_to_be_updated],
                  to: :published, after: proc { |*_args|
        update!("published_at": Time.now.utc)
      }
    end

    event :remove do
      transitions from: %i[published need_to_be_updated drafted unpublished],
                  to: :removed, after: proc { |*_args|
        update!(published_at: nil)
      }
    end

    event :unpublish do
      transitions from: %i[published need_to_be_updated],
                  to: :unpublished, after: proc { |*_args|
        update!(published_at: nil)
      }
    end

    event :split do
      transitions from: %i[published need_to_be_updated drafted unpublished],
                  to: :splitted, after: proc { |*_args|
        # update!(published_at: nil) TODO
      }
    end

    event :need_update do
      transitions from: %i[published drafted unpublished need_to_be_updated],
                  to: :need_to_be_updated, after: proc { |*_args|
        update!(published_at: nil)
      }
    end
  end

  # Methods
  def having_weeks_over_several_school_years?
    next_year_first_date = SchoolYear::Current.new
                                              .next_year
                                              .beginning_of_period
    last_date > next_year_first_date
  end

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
    InternshipOfferWeek.where(internship_offer_id: id)
                       .where('internship_offer_weeks.blocked_applications_count < ?', max_students_per_group)
                       .count
                       .positive?
  end

  def is_fully_editable?
    internship_applications.empty?
  end

  def next_year_week_ids
    weeks.to_a
          .intersection(Week.selectable_on_next_school_year.to_a)
          .map(&:id)
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

  def split_in_two
    original_week_ids = week_ids
    print '.'
    return nil if next_year_week_ids.empty?

    internship_offer = duplicate
    internship_offer.week_ids = next_year_week_ids
    internship_offer.remaining_seats_count = max_candidates
    internship_offer.employer = employer
    if internship_offer.valid?
      internship_offer.save
    else
      raise StandardError.new "##{internship_offer.errors.full_messages} - on #{internship_offer.errors.full_messages}"
    end

    self.week_ids = original_week_ids - next_year_week_ids
    self.hidden_duplicate = true
    self.split!
    save!

    internship_offer
  end

  def shown_as_masked?
    !published?
  end

  def departement
    Department.lookup_by_zipcode(zipcode: zipcode)
  end

  def operator
    return nil if !from_api?
    employer.operator
  end

  def from_api?
    permalink.present?
  end

  def has_weeks_in_the_future?
    weeks.map { |w| w.week_date > Time.now}.any?
  end

  def reserved_to_school?
    school.present?
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
                    siret employer_manual_enter internship_offer_area_id
                    contact_phone internship_offer_info_id organisation_id tutor_id
                    weekly_hours daily_hours lunch_break]

    internship_offer = generate_offer_from_attributes(white_list)
    organisation = self.organisation.dup
    internship_offer.organisation = organisation
    internship_offer
  end

  def duplicate_without_location
    white_list_without_location = %w[type title sector_id max_candidates
                    tutor_name tutor_phone tutor_email tutor_role employer_website
                    employer_name is_public group school_id coordinates
                    first_date last_date siret employer_manual_enter
                    internship_offer_area_id
                    internship_offer_info_id organisation_id tutor_id
                    weekly_hours daily_hours]

    generate_offer_from_attributes(white_list_without_location)
  end

  def update_from_organisation
    return unless organisation

    self.employer_name = organisation.employer_name
    self.employer_website = organisation.employer_website
    self.employer_description = organisation.employer_description
    self.siret = organisation.siret
    self.group_id = organisation.group_id
    self.is_public = organisation.is_public
  end

  def update_organisation
    return unless organisation && !organisation.new_record?

    # return si aucun changement qui concerne organisation
    organisation.update_columns(employer_name: self.employer_name) if attribute_changed?(:employer_name)
    organisation.update_columns(employer_website: self.employer_website) if attribute_changed?(:employer_website)
    organisation.update_columns(employer_description: self.employer_description) if attribute_changed?(:employer_description)
    organisation.update_columns(siret: self.siret) if attribute_changed?(:siret)
    organisation.update_columns(group_id: self.group_id) if attribute_changed?(:group_id)
    organisation.update_columns(is_public: self.is_public) if attribute_changed?(:is_public)
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

  def daily_planning?
    return false if daily_hours.blank?
    daily_hours.except('samedi').values.flatten.any? { |v| !v.blank? }
  end

  def presenter
    Presenters::InternshipOffer.new(self)
  end

  def is_favorite?(user)
    return false if user.nil?

    user.favorites.exists?(internship_offer_id: id)
  end

  def update_all_favorites
    if approved_applications_count >= max_candidates || Time.now > last_date
      Favorite.where(internship_offer_id: id).destroy_all
    end
  end
  
  def no_remaining_seat_anymore?
    remaining_seats_count.zero?
  end

  def requires_updates?
    may_need_update? && (!has_weeks_in_the_future? || no_remaining_seat_anymore?)
  end

  def available_weeks
    return Week.selectable_from_now_until_end_of_school_year unless respond_to?(:weeks)
    return Week.selectable_from_now_until_end_of_school_year unless persisted?
    if weeks&.first.nil?
      return Week.selectable_for_school_year(
        school_year: SchoolYear::Floating.new(date: Date.today)
      )
    end

    school_year = SchoolYear::Floating.new(date: weeks.first.week_date)

    Week.selectable_on_specific_school_year(school_year: school_year)
  end

  def requires_update_at_toggle_time?
    return false if published?

    !has_weeks_in_the_future? || no_remaining_seat_anymore?
  end

  def available_weeks_when_editing
    return nil unless persisted? && respond_to?(:weeks)
    Week.selectable_from_now_until_end_of_school_year
  end

  def approved_applications_current_school_year
    internship_applications.approved.current_school_year
  end

  def log_view(user)
    history = UsersInternshipOffersHistory.find_or_initialize_by(internship_offer: self, user: user)
    history.views += 1
    history.save
  end

  def log_apply(user)
    history = UsersInternshipOffersHistory.find_or_initialize_by(internship_offer: self, user: user)
    history.application_clicks += 1
    history.save
  end

  def create_stats
    stats = InternshipOfferStats.create(internship_offer: self)
    stats.recalculate
  end

  def update_stats
    stats.recalculate
  end
  
  # TODO Rename
  def missing_weeks_info?
    internship_offer_weeks.map(&:week_id).all? do |week_id|
      week_id < Week.current.id.to_i + 1
    end
  end

  def missing_weeks_in_the_future
    if missing_weeks_info?
      errors.add(weeks_class, 'Vous devez sélectionner au moins une semaine dans le futur')
    end
  end

  def check_for_missing_seats
    if no_remaining_seat_anymore?
      errors.add(:max_candidates, 'Augmentez Le nombre de places disponibles pour accueillir des élèves')
    end
  end

  def check_missing_seats_or_weeks
    return false if published_at.nil? # different from published? since published? checks the database and the former state of the object
    return false if republish.nil?

    missing_weeks_in_the_future && check_for_missing_seats
  end

  def user_update?
    user_update == "true"
  end
  
  protected

  def make_sure_area_is_set
    return if internship_offer_area_id.present?

    if employer&.current_area_id.nil?
      Rails.logger.error("no internship_offer_area with " \
                         "internship_offer_id: #{id} and " \
                         "employer_id: #{employer_id}")
    end
    self.internship_offer_area_id = employer.current_area_id
    Rails.logger.warn("default internship_offer_area with " \
                         "internship_offer_id: #{id} and " \
                         "employer_id: #{employer_id}")
  end
end
