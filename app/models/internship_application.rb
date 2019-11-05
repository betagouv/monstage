# frozen_string_literal: true

# application from student to internship_offer ; linked with weeks
class InternshipApplication < ApplicationRecord
  include AASM
  PAGE_SIZE = 10

  belongs_to :internship_offer_week
  belongs_to :student, class_name: 'Users::Student',
                       foreign_key: 'user_id'

  accepts_nested_attributes_for :student, update_only: true

  has_one :internship_offer, through: :internship_offer_week

  has_one :week, through: :internship_offer_week
  validates :motivation, :internship_offer_week, presence: true, unless: :application_via_school_manager?
  validates :student, uniqueness: { scope: :internship_offer_week_id }
  before_validation :internship_offer_has_spots_left?, on: :create
  before_validation :internship_offer_week_has_spots_left?, on: :create
  before_validation :at_most_one_application_per_student?, on: :create

  delegate :update_all_counters, to: :internship_application_counter_hook
  delegate :name, to: :student, prefix: true
  after_save :update_all_counters
  attr_reader :student_ids
  paginates_per PAGE_SIZE

  scope :order_by_aasm_state, lambda {
    select("#{table_name}.*")
      .select(%(
      CASE
        WHEN aasm_state = 'convention_signed' THEN 0
        WHEN aasm_state = 'drafted' THEN 1
        WHEN aasm_state = 'approved' THEN 2
        WHEN aasm_state = 'submitted' THEN 3
        WHEN aasm_state = 'rejected' THEN 4
        ELSE 0
      END as orderable_aasm_state
    ))
      .order('orderable_aasm_state')
  }

  scope :for_user, ->(user:) { where(user_id: user.id) }
  scope :not_by_id, ->(id:) { where.not(id: id) }

  def student_is_male?
    student.gender == 'm'
  end

  def student_is_custom_track?
    student.custom_track?
  end

  def internship_offer_has_spots_left?
    return unless internship_offer_week.present?
    unless internship_offer.has_spots_left?
      errors.add(:internship_offer, :has_no_spots_left)
    end
  end

  def internship_offer_week_has_spots_left?
    unless internship_offer_week.try(:has_spots_left?)
      errors.add(:internship_offer_week, :has_no_spots_left)
    end
  end

  def at_most_one_application_per_student?
    return unless internship_offer_week.present?
    if internship_offer.internship_applications.where(user_id: self.user_id).count > 0
      errors.add(:user_id, :duplicate)
    end
  end

  def internship_application_counter_hook
    InternshipApplicationCountersHook.new(internship_application: self)
  end

  def application_via_school_manager?
    internship_offer && internship_offer.school
  end

  def transition_with_email
    new_state = self.aasm.to_state
    update!(:"#{new_state}_at" => Time.now.utc)
    mailer = new_state == :submitted ? EmployerMailer : StudentMailer
    mailer.send(:"internship_application_#{new_state}_email",
                internship_application: self)
          .deliver_later
  end

  aasm do
    state :drafted, initial: true
    state :submitted, :approved, :rejected, :convention_signed

    event :submit do
      transitions from: :drafted, to: :submitted, after: :transition_with_email
    end

    event :approve do
      transitions from: :submitted, to: :approved, after: :transition_with_email
    end

    event :reject do
      transitions from: :submitted, to: :rejected, after: :transition_with_email
    end

    event :cancel do
      transitions from: %i[drafted submitted approved], to: :rejected, after: proc { |*_args|
        update!(rejected_at: Time.now.utc)
      }
    end

    event :signed do
      transitions from: :approved, to: :convention_signed, after: proc { |*_args|
        update!(convention_signed_at: Time.now.utc)
        student.cancel_application_on_week(week: internship_offer_week.week,
                                           keep_internship_application_id: id)
      }
    end
  end

  def anonymize
    update(motivation: 'NA')
  end
end
