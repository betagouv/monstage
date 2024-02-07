class InternshipOfferStats < ApplicationRecord
  # Relations
  belongs_to :internship_offer, inverse_of: :stats
  has_many :internship_applications, through: :internship_offer

  # Validations
  validates :internship_offer, presence: true, uniqueness: true

  # Callbacks
  after_create :recalculate
  after_update :check_remaining_seats

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
      remaining_seats_count: remaining_seats,
      update_needed: update_needed?
    )
    puts '------recalculate------'
    puts 'La valeur de update_needed est : ' + update_needed?.to_s
    puts '-----------------------'
  end
  
  def update_needed?
    puts 'update_needed? : ' + (internship_offer.may_need_update? && (!internship_offer.has_weeks_in_the_future? || remaining_seats.zero?)).to_s
    puts 'internship_applications.count : ' + internship_applications.count.to_s
    puts 'remaining_seats : ' + remaining_seats.to_s
    if remaining_seats.zero?
      puts internship_offer.may_need_update?
      puts !internship_offer.has_weeks_in_the_future?
      puts internship_offer.no_remaining_seat_anymore?
      puts remaining_seats_count
      puts remaining_seats
      puts internship_offer.may_need_update? && (!internship_offer.has_weeks_in_the_future? || remaining_seats.zero?)
    end
    internship_offer.may_need_update? && (!internship_offer.has_weeks_in_the_future? || remaining_seats.zero?)
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

  def check_remaining_seats
    internship_offer.update_column(:published_at, nil) if remaining_seats_count.zero?
  end
end
