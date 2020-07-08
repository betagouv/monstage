# frozen_string_literal: true

class InternshipOffer < ApplicationRecord
  TITLE_MAX_CHAR_COUNT = 150
  DESCRIPTION_MAX_CHAR_COUNT = 500
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250
  PAGE_SIZE = 30
  MAX_CANDIDATES_PER_GROUP = 200

  # queries
  include Listable
  include FindableWeek
  include Nearbyable
  include Zipcodable

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
    where("last_date > :now", now: Time.now)
  }

  enum school_type: {
    middle_school: 'middle_school',
    high_school: 'high_school'
  }

  validates :title,
            :employer_name,
            :city,
            :school_type,
            presence: true

  validates :title, presence: true,
                    length: { maximum: TITLE_MAX_CHAR_COUNT }

  validates :description, presence: true,
                          length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

  validates :employer_description, length: { maximum: EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT }

  has_rich_text :description_rich_text
  has_rich_text :employer_description_rich_text

  belongs_to :employer, polymorphic: true
  belongs_to :sector
  belongs_to :school, optional: true # reserved to school
  belongs_to :group, optional: true

  before_validation :replicate_rich_text_to_raw_fields
  before_save :sync_first_and_last_date,
              :reverse_academy_by_zipcode

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
    true
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
    white_list = %w[type title sector_id max_candidates school_type
                    tutor_name tutor_phone tutor_email employer_website
                    employer_name street zipcode city department region academy
                    is_public group school_id coordinates first_date last_date]

    internship_offer = InternshipOffer.new(attributes.slice(*white_list))
    internship_offer.description_rich_text = (description_rich_text.present? ?
                                              description_rich_text.to_s :
                                              description)
    internship_offer.employer_description_rich_text = (employer_description_rich_text.present? ?
                                                       employer_description_rich_text.to_s :
                                                       employer_description)

    internship_offer
  end

  def class_prefix_for_multiple_checkboxes
    'internship_offer'
  end

  #
  # callbacks
  #
  def sync_first_and_last_date
    ordered_weeks = weeks.sort{ |a, b| [a.year, a.number] <=> [b.year, b.number] }
    first_week, last_week = ordered_weeks.first, ordered_weeks.last
    self.first_date = first_week.week_date.beginning_of_week
    self.last_date = last_week.week_date.end_of_week
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
    if description_rich_text.to_s.present?
      self.description = description_rich_text.to_plain_text
    end
    if employer_description_rich_text.to_s.present?
      self.employer_description = employer_description_rich_text.to_plain_text
    end
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
