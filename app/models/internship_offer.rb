# frozen_string_literal: true

class InternshipOffer < ApplicationRecord
  include Discard::Model
  include Nearbyable

  PAGE_SIZE = 10

  validates :title,
            :tutor_name,
            :tutor_phone,
            :tutor_email,
            :max_internship_week_number,
            :employer_name,
            :zipcode,
            :city,
            presence: true

  validates :is_public, inclusion: { in: [true, false] }
  validates :group, inclusion: { in: Group::PUBLIC, message: 'Veuillez choisir une institution de tutelle' },
                    if: :is_public?
  validates :group, inclusion: { in: Group::PRIVATE, message: 'Veuillez choisir une institution de tutelle' },
                    unless: :is_public?,
                    allow_blank: true,
                    allow_nil: true

  MAX_CANDIDATES_PER_GROUP = 200
  validates :max_candidates, numericality: { only_integer: true,
                                             greater_than: 0,
                                             less_than_or_equal_to: MAX_CANDIDATES_PER_GROUP }

  validates :max_internship_week_number, numericality: { only_integer: true, greater_than: 0 }

  validates :weeks, presence: true

  DESCRIPTION_MAX_CHAR_COUNT = 500
  OLD_DESCRIPTION_MAX_CHAR_COUNT = 715 # here for backward compatibility
  validates :description, presence: true, length: { maximum: OLD_DESCRIPTION_MAX_CHAR_COUNT }
  validates :employer_description, length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

  has_many :internship_offer_weeks, dependent: :destroy
  has_many :internship_applications, through: :internship_offer_weeks, dependent: :destroy

  has_many :weeks, through: :internship_offer_weeks
  has_many :internship_offer_operators, dependent: :destroy
  has_many :operators, through: :internship_offer_operators

  belongs_to :employer, polymorphic: true
  belongs_to :school, optional: true # reserved to school
  belongs_to :sector

  scope :for_user, lambda { |user:|
    return merge(all) unless user # fuck it ; should have a User::Visitor type

    merge(user.class.targeted_internship_offers(user: user))
  }
  scope :by_sector, lambda { |sector_id|
    where(sector_id: sector_id)
  }
  scope :by_weeks, lambda { |weeks:|
    joins(:weeks).where(weeks: { id: weeks.ids }).distinct
  }

  scope :older_than, lambda { |week:|
    joins(:weeks).where('weeks.year > ? OR (weeks.year = ? AND weeks.number > ?)', week.year, week.year, week.number)
  }

  scope :available_in_the_future, lambda {
    older_than(week: Week.current).distinct
  }

  after_initialize :init
  before_create :reverse_academy_by_zipcode
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

  def osm_url
    "http://www.openstreetmap.org/?mlat=#{coordinates.lat}&mlon=#{coordinates.lon}&zoom=12"
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
  end

  def total_female_applications_count
    total_applications_count - total_male_applications_count
  end

  def total_female_convention_signed_applications_count
    convention_signed_applications_count - total_male_convention_signed_applications_count
  end

  def reverse_academy_by_zipcode
    self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
  end
end
