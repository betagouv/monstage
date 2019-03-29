class InternshipOffer < ApplicationRecord
  include Discard::Model
  include Nearbyable
  PAGE_SIZE = 10

  validates :title,
            :tutor_name,
            :tutor_phone,
            :tutor_email,
            :employer_name,
            :employer_street,
            :employer_zipcode,
            :employer_city,
            presence: true

  validates :is_public, inclusion: { in: [true, false] }

  validates :max_candidates, numericality: { only_integer: true, greater_than: 0 },
                             unless: :is_individual?
  validates :max_internship_number, numericality: { only_integer: true, greater_than: 0 }

  validates :weeks, presence: true

  AVERAGE_CHAR_PER_WORD = 5.5
  DESCRIPTION_MIN_WORD_COUNT = 2
  DESCRIPTION_MAX_WORD_COUNT = 130
  DESCRIPTION_MIN_CHAR_COUNT = (DESCRIPTION_MIN_WORD_COUNT * AVERAGE_CHAR_PER_WORD).ceil
  DESCRIPTION_MAX_CHAR_COUNT = (DESCRIPTION_MAX_WORD_COUNT * AVERAGE_CHAR_PER_WORD).ceil
  validates_length_of :description, minimum: DESCRIPTION_MIN_CHAR_COUNT,
                                    maximum: DESCRIPTION_MAX_CHAR_COUNT,
                                    allow_blank: false

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :weeks, through: :internship_offer_weeks
  has_many :internship_applications, through: :internship_offer_weeks
  belongs_to :employer, class_name: "Users::Employer"

  belongs_to :school, optional: true # reserved to school
  belongs_to :sector

  scope :for_user, -> (user:) {
    return merge(all) unless user # fuck it ; should have a User::Visitor type
    merge(user.class.targeted_internship_offers(user: user))
  }
  scope :by_weeks, -> (weeks:) {
    joins(:weeks).where(weeks: {id: weeks.ids}).distinct
  }

  scope :filter_by_sector, -> (sector_id) {
    where(sector_id: sector_id)
  }

  paginates_per PAGE_SIZE

  def available_all_year?
    week_day_start.blank? && week_day_end.blank?
  end

  def is_individual?
    max_candidates.blank? || max_candidates == 1
  end

  def formatted_autocomplete_address
    [
      employer_street,
      employer_city,
      employer_zipcode
    ].compact.uniq.join(', ')
  end
end
