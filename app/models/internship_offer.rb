# frozen_string_literal: true

class InternshipOffer < ApplicationRecord
  PAGE_SIZE = 30
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250
  MAX_CANDIDATES_PER_GROUP = 200
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

  # public.config_search_with_synonym config is
  # this TEXT SEARCH CONFIGURATION is based on 3 keys concepts
  #   public.dict_search_with_synonoym : why allow us to links kind of same words for input search
  #   unaccent : which tokenize content without accent [search is also applied without accent]
  # .  french stem : which tokenize content for french FT
  # plus some customization to ignores
  #   email, url, host, file, int, float
  pg_search_scope :search_by_keyword,
                  against: {
                    title: 'A',
                    description: 'B',
                    employer_description: 'C'
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'public.config_search_with_synonym',
                      tsvector_column: 'search_tsv',
                      prefix: true
                    }
                  }

  scope :by_sector, lambda { |sector_id|
    where(sector_id: sector_id)
  }

  scope :limited_to_department, lambda { |user:|
    where(department: user.department_name)
  }

  scope :from_api, lambda {
    where.not(permalink: nil)
  }

  scope :not_from_api, lambda {
    where(permalink: nil)
  }

  scope :submitted_by_operator, lambda { |user:|
    merge(user.operator.internship_offers)
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

  scope :ignore_max_internship_offer_weeks_reached, lambda {
    all # TODO : specs for FreeDate required
  }

  scope :school_track, lambda { |school_track:|
    where(school_track: school_track)
  }

  scope :unpublished, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

  scope :weekly_framed, lambda {
    where(type: [InternshipOffers::WeeklyFramed.name,
                 InternshipOffers::Api.name])
  }

  scope :free_date, lambda {
    where(type: InternshipOffers::FreeDate.name)
  }

  has_many :internship_applications, as: :internship_offer,
                                     foreign_key: 'internship_offer_id'

  belongs_to :employer, polymorphic: true

  has_one :organisation
  has_one :tutor
  has_one :internship_offer_info

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

  def departement
    Department.lookup_by_zipcode(zipcode: zipcode)
  end

  def published?
    published_at.present?
  end

  def unpublished?
    !published?
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

  def total_female_applications_count
    total_applications_count - total_male_applications_count
  end

  def total_female_convention_signed_applications_count
    convention_signed_applications_count - total_male_convention_signed_applications_count
  end

  def anonymize
    fields_to_reset = {
      tutor_name: 'NA',
      tutor_phone: 'NA',
      tutor_email: 'NA',
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
    white_list = %w[type title sector_id max_candidates
                    tutor_name tutor_phone tutor_email employer_website
                    employer_name street zipcode city department region academy
                    is_public group school_id coordinates first_date last_date
                    school_track
                    internship_offer_info_id organisation_id tutor_id
                    weekly_hours new_daily_hours]

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
end
