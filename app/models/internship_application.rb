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

  delegate :update_all_counters, to: :internship_application_counter_hook
  after_save :update_all_counters

  paginates_per PAGE_SIZE

  def internship_offer_week_has_spots_left
    unless internship_offer_week && internship_offer_week.has_spots_left?
      errors[:base] << "Impossible de candidater car l'offre est déjà pourvue"
    end
  end

  def internship_application_counter_hook
    InternshipApplicationCountersHook.new(internship_application: self)
  end

  aasm do
    state :submitted, initial: true
    state :approved, :rejected, :convention_signed

    event :approve do
      transitions from: :submitted, to: :approved, :after => Proc.new { |*args|
        update!(approved_at: Time.now.utc)
        StudentMailer.internship_application_approved_email(internship_application: self)
                     .deliver_later
      }
    end

    event :reject do
      transitions from: :submitted, to: :rejected, :after => Proc.new { |*args|
        update!(rejected_at: Time.now.utc)
        StudentMailer.internship_application_rejected_email(internship_application: self)
                     .deliver_later
      }
    end

    event :cancel do
      transitions from: :approved, to: :rejected, :after => Proc.new { |*args|
        update!(rejected_at: Time.now.utc)
      }
    end

    event :signed do
      transitions from: :approved, to: :convention_signed, :after => Proc.new { |*args|
        update!(convention_signed_at: Time.now.utc)
      }
    end
  end
end
