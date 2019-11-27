# frozen_string_literal: true

module BaseInternshipOffer
  extend ActiveSupport::Concern
  TITLE_MAX_CHAR_COUNT = 150
  OLD_DESCRIPTION_MAX_CHAR_COUNT = 750
  DESCRIPTION_MAX_CHAR_COUNT = 500
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250

  included do
    include Discard::Model

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

    before_validation :replicate_rich_text_to_raw_fields
    before_save :reverse_academy_by_zipcode,
                :reverse_department_by_zipcode

    before_create :preset_published_at_to_now

    scope :published, -> { where.not(published_at: nil) }

    def reverse_academy_by_zipcode
      self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
    end

    def reverse_department_by_zipcode
      self.department = Department.lookup_by_zipcode(zipcode: zipcode)
    end

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
  end
end
