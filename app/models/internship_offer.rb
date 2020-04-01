# frozen_string_literal: true

class InternshipOffer < ApplicationRecord
  TITLE_MAX_CHAR_COUNT = 150
  OLD_DESCRIPTION_MAX_CHAR_COUNT = 750
  DESCRIPTION_MAX_CHAR_COUNT = 500
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250
  PAGE_SIZE = 30
  MAX_CANDIDATES_PER_GROUP = 200

  # queries
  include Listable
  include FindableWeek
  include Nearbyable

  # utils
  include Discard::Model
  include PgSearch::Model

  pg_search_scope :search_by_term,
                  against: {
                    title: 'A',
                    description: 'B',
                    employer_description: 'C'
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'public.config_search_with_synonym',
                      tsvector_column: "search_tsv",
                      prefix: true,
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

  scope :ignore_max_candidates_reached, lambda {
    joins(:internship_offer_weeks)
     .where('internship_offer_weeks.blocked_applications_count < internship_offers.max_candidates')
  }

  scope :ignore_max_internship_offer_weeks_reached, lambda {
    where('internship_offer_weeks_count > blocked_weeks_count')
  }

  scope :ignore_already_applied, lambda { |user: |
    where.not(id: joins(:internship_applications)
                    .merge(InternshipApplication.where(user_id: user.id)))
  }

  scope :mines_and_sumbmitted_to_operator, lambda { |user:|
      left_joins(:internship_offer_operators)
       .merge(where(internship_offer_operators: {operator_id: user.operator_id})
              .or(where("internship_offers.employer_id = #{user.id}")))
  }

  scope :ignore_internship_restricted_to_other_schools, lambda { |school_id:|
    where(school_id: [nil, school_id])
  }

  scope :internship_offers_overlaping_school_weeks, lambda { |weeks:|
    by_weeks(weeks: weeks)
  }

  validates :title,
            :employer_name,
            :zipcode,
            :city,
            presence: true

  validates :title, presence: true,
                    length: { maximum: TITLE_MAX_CHAR_COUNT },
                    if: :ready_to_enforce_less_text?

  validates :description, presence: true,
                          length: { maximum: OLD_DESCRIPTION_MAX_CHAR_COUNT },
                          unless: :ready_to_enforce_less_text?

  validates :description, presence: true,
                          length: { maximum: DESCRIPTION_MAX_CHAR_COUNT },
                          if: :ready_to_enforce_less_text?

  validates :employer_description, length: { maximum: EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT }
  validates :weeks, presence: true

  has_rich_text :description_rich_text
  has_rich_text :employer_description_rich_text

  belongs_to :employer, polymorphic: true
  belongs_to :sector

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :weeks, through: :internship_offer_weeks

  has_many :internship_applications, through: :internship_offer_weeks,
                                     dependent: :destroy
  has_many :internship_offer_operators, dependent: :destroy
  has_many :operators, through: :internship_offer_operators

  belongs_to :school, optional: true # reserved to school
  belongs_to :group, optional: true

  before_validation :replicate_rich_text_to_raw_fields
  before_save :sync_first_and_last_date,
              :reverse_academy_by_zipcode,
              :reverse_department_by_zipcode

  before_create :preset_published_at_to_now
  after_commit :sync_internship_offer_keywords

  scope :published, -> { where.not(published_at: nil) }

  paginates_per PAGE_SIZE

  def published?
    published_at.present?
  end

  def unpublished?
    !published?
  end

  def has_operator?
    !operators.empty?
  end

  def is_individual?
    max_candidates == 1
  end

  def from_api?
    permalink.present?
  end

  def reserved_to_school?
    school.present?
  end

  def is_fully_editable?
    internship_applications.empty?
  end


  def total_female_applications_count
    total_applications_count - total_male_applications_count
  end

  def total_female_convention_signed_applications_count
    convention_signed_applications_count - total_male_convention_signed_applications_count
  end

  def anonymize
    fields_to_reset = {
      tutor_name: 'NA', tutor_phone: 'NA', tutor_email: 'NA', title: 'NA',
      description: 'NA', employer_website: 'NA', street: 'NA',
      employer_name: 'NA', employer_description: 'NA'
    }
    update(fields_to_reset)
    discard
  end

  def class_prefix_for_multiple_checkboxes
    'internship_offer'
  end


  #
  # callbacks
  #
  def sync_first_and_last_date
    first_week, last_week = weeks.minmax_by(&:id)
    self.first_date = first_week.week_date.beginning_of_week
    self.last_date = last_week.week_date.end_of_week
  end

  def reverse_academy_by_zipcode
    self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
  end

  def reverse_department_by_zipcode
    self.department = Department.lookup_by_zipcode(zipcode: zipcode)
  end

  # @note some possible confusion, miss-understanding here
  #   1. Rich text was added after API
  #   2. API already exposed a "description" attributes (not rich text) [in/out]
  #     trying to upgrade description attribute was flacky
  #     because API returned description as an ActionText record.
  #   3. To avoid any circumvention (in/out) of the description
  #     we add a new description_rich_text element which is rendered when possiblee
  #   4. Bonus -> description will be used for description_tsv as template to extract keywords
  def replicate_rich_text_to_raw_fields
    self.description = self.description_rich_text.to_plain_text if self.description_rich_text.to_s.present?
    self.employer_description = self.employer_description_rich_text.to_plain_text if self.employer_description_rich_text.to_s.present?
  end

  def preset_published_at_to_now
    self.published_at = Time.now
  end

  def ready_to_enforce_less_text?
    Date.today.year >= 2019 && Date.today.month >= 9 ||
    Date.today.year >= 2020
  end

  def sync_internship_offer_keywords
    SyncInternshipOfferKeywordsJob.perform_later
  end
end
