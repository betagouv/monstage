class InternshipOfferStats < ApplicationRecord
  # Relations
  belongs_to :internship_offer, inverse_of: :stats
  has_many :internship_applications, through: :internship_offer

  # Validations
  validates :internship_offer, presence: true, uniqueness: true

  # Callbacks
  after_create :recalculate
  after_update :check_update_needed?

  def recalculate
    update(
      blocked_weeks_count: blocked_weeks,
      total_applications_count: total_applications,
      total_male_applications_count: total_male_applications,
      total_female_applications_count: total_female_applications,
      approved_applications_count: approved_applications,
      total_male_approved_applications_count: total_male_approved_applications,
      total_female_approved_applications_count: total_female_approved_applications,
      rejected_applications_count: rejected_applications,
      submitted_applications_count: submitted_applications,
      remaining_seats_count: remaining_seats
    )
  end
  
  private
  #---------------------------------------
  # blocked_weeks_count
  # counts the number of weeks with any positive number of approved applications
  # in each week for a given internship offer
  #---------------------------------------
  def blocked_weeks
    internship_offer.internship_offer_weeks
                     .where('internship_offer_weeks.blocked_applications_count > 0')
                     .count
  end

  def total_applications
    internship_offer.internship_applications
                    .reject(&:drafted?)
                    .count
  end

  def total_male_applications
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .reject(&:drafted?)
                    .select(&:student_is_male?)
                    .count
  end

  def total_female_applications
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .reject(&:drafted?)
                    .select(&:student_is_female?)
                    .count
  end

  def approved_applications
    internship_applications
                    .select(&:approved?)
                    .count
  end

  def total_male_approved_applications
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .select(&:approved?)
                    .select(&:student_is_male?)
                    .count
  end

  def total_female_approved_applications
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .select(&:approved?)
                    .select(&:student_is_female?)
                    .count
  end

  def rejected_applications
    internship_offer.internship_applications
                    .select(&:rejected?)
                    .count
  end

  def submitted_applications
    internship_offer.internship_applications
                    .select(&:submitted?)
                    .count
  end

  def remaining_seats
    reserved_places = internship_offer.internship_offer_weeks&.sum(:blocked_applications_count)
    internship_offer.max_candidates - reserved_places
  end

  def check_update_needed?
    return unless internship_offer.requires_updates?
    internship_offer.update_columns(aasm_state: 'need_to_be_updated', published_at: nil)
  end
end
