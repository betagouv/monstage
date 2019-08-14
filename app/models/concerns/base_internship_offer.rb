# frozen_string_literal: true

module BaseInternshipOffer
  extend ActiveSupport::Concern

  DESCRIPTION_MAX_CHAR_COUNT = 500
  OLD_DESCRIPTION_MAX_CHAR_COUNT = 715 # here for backward compatibility
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 250
  included do
    include Discard::Model

    validates :title,
              :employer_name,
              :zipcode,
              :city,
              presence: true

    validates :description, presence: true, length: { maximum: OLD_DESCRIPTION_MAX_CHAR_COUNT }
    validates :employer_description, length: { maximum: EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT }

    validates :weeks, presence: true

    belongs_to :employer, polymorphic: true
    belongs_to :sector

    has_many :internship_offer_weeks, dependent: :destroy
    has_many :weeks, through: :internship_offer_weeks

    before_create :reverse_academy_by_zipcode

    def reverse_academy_by_zipcode
      self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
    end
  end
end
