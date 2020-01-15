# frozen_string_literal: true

class InternshipOffer < ApplicationRecord
  # queries
  include Nearbyable
  include Listable
  include FindableWeek
  # base
  include BaseInternshipOffer

  PAGE_SIZE = 30

  rails_admin do
    list do
      field :title
      field :zipcode
      field :employer_name
      field :group
      field :is_public
      field :department
      field :created_at
    end

    show do
      exclude_fields :blocked_weeks_count,
                     :total_applications_count,
                     :convention_signed_applications_count,
                     :approved_applications_count,
                     :total_male_applications_count,
                     :total_male_convention_signed_applications_count,
                     :total_custom_track_convention_signed_applications_count,
                     :submitted_applications_count,
                     :rejected_applications_count
    end

    edit do
      field :title
      field :description
      field :max_candidates
      field :tutor_name
      field :tutor_phone
      field :tutor_email
      field :employer_website
      field :discarded_at
      field :employer_name
      field :is_public
      field :group
      field :employer_description
      field :published_at
    end

    export do
      field :title
      field :employer_name
      field :group
      field :zipcode
      field :city
      field :max_candidates
      field :total_applications_count
      field :convention_signed_applications_count
    end
  end

  validates :street,
            :city,
            :tutor_name,
            :tutor_phone,
            :tutor_email,
            presence: true

  validates :is_public, inclusion: { in: [true, false] }
  validate :validate_group_is_public?, if: :is_public?
  validate :validate_group_is_not_public?, unless: :is_public?

  MAX_CANDIDATES_PER_GROUP = 200
  validates :max_candidates, numericality: { only_integer: true,
                                             greater_than: 0,
                                             less_than_or_equal_to: MAX_CANDIDATES_PER_GROUP }


  has_many :internship_applications, through: :internship_offer_weeks,
                                     dependent: :destroy
  has_many :internship_offer_operators, dependent: :destroy
  has_many :operators, through: :internship_offer_operators

  belongs_to :school, optional: true # reserved to school
  belongs_to :group, optional: true
  scope :for_user, lambda { |user:, coordinates:|
    return merge(all) unless user # fuck it ; should have a User::Visitor type

    merge(user.class.targeted_internship_offers(user: user, coordinates: coordinates))
  }
  scope :by_sector, lambda { |sector_id|
    where(sector_id: sector_id)
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

  def from_api?
    permalink.present?
  end

  def reserved_to_school?
    school.present?
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
      tutor_name: 'NA', tutor_phone: 'NA', tutor_email: 'NA', title: 'NA',
      description: 'NA', employer_website: 'NA', street: 'NA',
      employer_name: 'NA', employer_description: 'NA'
    }
    update(fields_to_reset)
    discard
  end

  def duplicate
    white_list = %w[title description sector_id max_candidates
                    tutor_name tutor_phone tutor_email employer_website
                    employer_name street zipcode city department region academy
                    is_public group school_id employer_description coordinates]

    internship_offer = InternshipOffer.new(attributes.slice(*white_list))
    internship_offer.week_ids = week_ids
    internship_offer.operator_ids = operator_ids
    internship_offer
  end

  def validate_group_is_public?
    return if group.nil?
    errors.add(:group, 'Veuillez choisir une institution de tutelle') unless group.is_public?
  end

  def validate_group_is_not_public?
    return if group.nil?
    errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
  end

end
