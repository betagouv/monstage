# frozen_string_literal: true

class InternshipOffer < ApplicationRecord
  include Nearbyable
  include BaseInternshipOffer

  PAGE_SIZE = 10

  validates :tutor_name,
            :tutor_phone,
            :tutor_email,
            :max_occurence,
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

  validates :max_occurence, numericality: { only_integer: true, greater_than: 0 }

  has_many :internship_applications, through: :internship_offer_weeks, dependent: :destroy

  has_many :internship_offer_operators, dependent: :destroy
  has_many :operators, through: :internship_offer_operators

  belongs_to :school, optional: true # reserved to school

  scope :for_user, lambda { |user:, coordinates:|
    return merge(all) unless user # fuck it ; should have a User::Visitor type

    merge(user.class.targeted_internship_offers(user: user, coordinates: coordinates))
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

  attr_reader :with_operator

  def is_individual?
    max_candidates == 1
  end

  def has_spots_left?
    internship_offer_weeks.any?(&:has_spots_left?)
  end

  def is_fully_editable?
    internship_applications.empty?
  end

  def has_operator?
    !operators.empty?
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

  def cleanup_RGPD
    fields_to_reset = {
      tutor_name: 'NA', tutor_phone: 'NA', tutor_email: 'NA', title: 'NA',
      description: 'NA', employer_website: 'NA', street: 'NA',
      employer_name: 'NA', employer_description: 'NA'
    }
    update(fields_to_reset)
    discard
  end
end
