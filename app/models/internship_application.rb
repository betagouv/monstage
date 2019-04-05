class InternshipApplication < ApplicationRecord
  include AASM
  PAGE_SIZE = 10

  belongs_to :internship_offer_week
  belongs_to :student, class_name: 'Users::Student', foreign_key: 'user_id'

  has_one :internship_offer, through: :internship_offer_week

  has_one :week, through: :internship_offer_week
  validates :motivation, :internship_offer_week, presence: true
  validates :student, uniqueness: { scope: :internship_offer_week_id }
  before_validation :internship_offer_week_has_spots_left, on: :create

  counter_culture :internship_offer_week,
                  column_name: proc  { |model| model.approved? ? 'blocked_applications_count' : nil },
                  column_names: {
                    ["aasm_state = ?", "approved"] => 'blocked_applications_count'
                  }
  counter_culture :internship_offer_week,
                  column_name: proc  { |model| model.approved? ? 'approved_applications_count' : nil },
                  column_names: {
                    ["aasm_state = ?", "approved"] => 'approved_applications_count'
                  }

  counter_culture :internship_offer, column_name: 'total_applications_count'

  paginates_per PAGE_SIZE

  def internship_offer_week_has_spots_left
    unless internship_offer_week && internship_offer_week.has_spots_left?
      errors[:base] << "Impossible de candidater car l'offre est déjà pourvue"
    end
  end

  aasm do
    state :submitted, initial: true
    state :approved, :rejected, :convention_signed

    event :approve do
      transitions from: :submitted, to: :approved, :after => Proc.new { |*args|
        StudentMailer.internship_application_approved_email(internship_application: self)
                     .deliver_later
      }
    end

    event :reject do
      transitions from: :submitted, to: :rejected, :after => Proc.new { |*args|
        StudentMailer.internship_application_rejected_email(internship_application: self)
                     .deliver_later
      }
    end

    event :cancel do
      transitions from: :approved, to: :rejected, :after => Proc.new { |*args| }
    end

    event :signed do
      transitions from: :approved, to: :convention_signed, :after => Proc.new { |*args| }
    end
  end
end
