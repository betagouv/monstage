# base class for hooks on internship_applications (compute various counters for dashboard/reporting
class InternshipApplicationCountersHook
  delegate :remaining_seats_count, to: :internship_application
  delegate :internship_offer, to: :internship_application
  delegate :week, to: :internship_application

  # BEWARE: order matters
  def update_all_counters
    update_internship_offer_week_counters
    internship_offer.update(
      internship_offer_counters_attributes.merge(
        blocked_weeks_count: blocked_weeks_count
      )
    )
    update_favorites
    true
  end

  def update_favorites
    internship_offer.update_all_favorites
  end

  # PERF: can be optimized with one query
  # w8 for perf issue [if it ever occures]
  # select sum(aasm_state == convention_signed) as convention_signed_count
  #        sum(aasm_state == approved) as approved_count )

  # :approved is the top aasm_state that an application can reach.
  # Agreements states are decoupled
  #---------------------------------------
  # blocked_applications_count is a column of InternshipOfferWeek
  # it counts the applications approved for each internship offer week.
  #---------------------------------------

  # Note: if a week is associated to an application that reaches the aasm_state of :approved,
  # and if that week in not listed in internship_offer_weeks,
  # then next counter could appear as bugged (see commit ad80245), but it is not

  def update_internship_offer_week_counters
    internship_offer_week = InternshipOfferWeek.find_by(
      internship_offer_id: internship_offer.id,
      week_id: week.id
    )
    return unless internship_offer_week

    internship_offer_week.update(
      blocked_applications_count: week.internship_applications
                                      .merge(InternshipApplication.approved)
                                      .where(internship_offer_id: internship_offer.id)
                                      .count
    )
  end

  def internship_offer_counters_attributes
    {
      total_applications_count: total_applications_count,
      total_male_applications_count: total_male_applications_count,
      total_female_applications_count: total_female_applications_count,
      submitted_applications_count: submitted_applications_count,
      approved_applications_count: approved_applications_count,
      total_male_approved_applications_count: total_male_approved_applications_count,
      total_female_approved_applications_count: total_female_approved_applications_count,
      rejected_applications_count: rejected_applications_count,
      convention_signed_applications_count: convention_signed_applications_count,
      total_male_convention_signed_applications_count: total_male_convention_signed_applications_count,
      total_female_convention_signed_applications_count: total_female_convention_signed_applications_count,
      remaining_seats_count: remaining_seats_count
    }
  end

  def total_applications_count
    internship_offer.internship_applications
                    .reject(&:drafted?)
                    .count
  end

  def total_male_applications_count
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .reject(&:drafted?)
                    .select(&:student_is_male?)
                    .count
  end

  def total_female_applications_count
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .reject(&:drafted?)
                    .select(&:student_is_female?)
                    .count
  end

  def approved_applications_count
    internship_offer.internship_applications
                    .select(&:approved?)
                    .count
  end

  def total_male_approved_applications_count
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .select(&:approved?)
                    .select(&:student_is_male?)
                    .count
  end

  def total_female_approved_applications_count
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .select(&:approved?)
                    .select(&:student_is_female?)
                    .count
  end

  def rejected_applications_count
    internship_offer.internship_applications
                    .select(&:rejected?)
                    .count
  end

  def submitted_applications_count
    internship_offer.internship_applications
                    .select(&:submitted?)
                    .count
  end

  def convention_signed_applications_count
    internship_offer.internship_applications
                    .select(&:convention_signed?)
                    .count
  end

  def total_male_convention_signed_applications_count
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .select(&:convention_signed?)
                    .select(&:student_is_male?)
                    .count
  end

  def total_female_convention_signed_applications_count
    internship_offer.internship_applications
                    .joins(:student)
                    .includes(:student)
                    .select(&:convention_signed?)
                    .select(&:student_is_female?)
                    .count
  end


  private

  attr_reader :internship_application

  def initialize(internship_application:)
    @internship_application = internship_application
    @internship_application.reload
  end

  #---------------------------------------
  # blocked_weeks_count
  # counts the number of weeks with any positive number of approved applications
  # in each week for a given internship offer
  #---------------------------------------
  def blocked_weeks_count
    internship_offer.internship_offer_weeks
                    .where('internship_offer_weeks.blocked_applications_count > 0')
                    .count
  end
end
