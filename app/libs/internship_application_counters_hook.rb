# base class for hooks on internship_applications (compute various counters for dashboard/reporting
class InternshipApplicationCountersHook
  delegate :remaining_seats_count, to: :internship_application
  def internship_offer_counters_attributes
    {
      total_applications_count:,
      total_male_applications_count:,
      total_female_applications_count:,
      submitted_applications_count:,
      approved_applications_count:,
      total_male_approved_applications_count:,
      total_female_approved_applications_count:,
      rejected_applications_count:,
      remaining_seats_count:
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

  private

  attr_reader :internship_application

  def initialize(internship_application:)
    @internship_application = internship_application
    @internship_application.reload
  end
end
