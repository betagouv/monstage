class InternshipOffer < ApplicationRecord
  include Discard::Model
  include Nearbyable
  PAGE_SIZE = 10

  MONTH_OF_YEAR_SHIFT = 5
  DAY_OF_YEAR_SHIFT = 31

  validates :title,
            :tutor_name,
            :tutor_phone,
            :tutor_email,
            :max_internship_week_number,
            :employer_name,
            :street,
            :zipcode,
            :city,
            presence: true

  validates :is_public, inclusion: { in: [true, false] }

  MAX_CANDIDATES_PER_GROUP = 200
  validates :max_candidates, numericality: { only_integer: true,
                                             greater_than: 0,
                                             less_than_or_equal_to: MAX_CANDIDATES_PER_GROUP }

  validates :max_internship_week_number, numericality: { only_integer: true, greater_than: 0 }

  validates :weeks, presence: true

  DESCRIPTION_MAX_CHAR_COUNT = 275
  OLD_DESCRIPTION_MAX_CHAR_COUNT = 715 # here for backward compatibility
  validates :description, presence: true, length: { maximum: OLD_DESCRIPTION_MAX_CHAR_COUNT }
  validates :employer_description, length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :internship_applications, through: :internship_offer_weeks
  has_many :weeks, through: :internship_offer_weeks

  has_many :internship_offer_operators, dependent: :destroy
  has_many :operators, through: :internship_offer_operators

  belongs_to :employer, polymorphic: true

  belongs_to :school, optional: true # reserved to school


  belongs_to :sector

  scope :for_user, -> (user:) {
    return merge(all) unless user # fuck it ; should have a User::Visitor type
    merge(user.class.targeted_internship_offers(user: user))
  }
  scope :by_sector, -> (sector_id) {
    where(sector_id: sector_id)
  }
  scope :by_weeks, -> (weeks:) {
    joins(:weeks).where(weeks: {id: weeks.ids}).distinct
  }

  scope :older_than, -> (week:) {
    joins(:weeks).where("weeks.year > ? OR (weeks.year = ? AND weeks.number > ?)", week.year, week.year, week.number)
  }

  scope :available_in_the_future, -> {
    older_than(week: Week.current).distinct
  }

  # year parameter is the first year from a school year.
  # For example, year would be 2019 for school year 2019/2020
  scope :during_year, -> (year:) {
    where("created_at > :date_begin", date_begin: Date.new(year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)).where("created_at <= :date_end", date_end: Date.new(year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT))
  }

  scope :during_current_year, -> {
    during_year(year: Date.today.month <= MONTH_OF_YEAR_SHIFT ? Date.today.year - 1 : Date.today.year)
  }

  after_initialize :init
  paginates_per PAGE_SIZE

  def is_individual?
    max_candidates == 1
  end

  def has_spots_left?
    internship_offer_weeks.any?(&:has_spots_left?)
  end

  def is_fully_editable?
    internship_applications.empty?
  end

  def formatted_autocomplete_address
    [
      street,
      city,
      zipcode
    ].compact.uniq.join(', ')
  end

  def init
   self.max_candidates ||= 1
   self.max_internship_week_number ||= 1
  end

end
