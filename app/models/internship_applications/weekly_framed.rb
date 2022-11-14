module InternshipApplications
  # wraps weekly logic
  class WeeklyFramed < InternshipApplication

    belongs_to :week, class_name: 'Week'

    after_save :update_all_counters

    validates :week_id,
              presence: true,
              unless: :application_via_school_manager?
    validates :student, uniqueness: { scope: [:internship_offer_id, :week_id] }

    before_validation :at_most_one_application_per_student?, on: :create
    before_validation :internship_offer_has_spots_left?, on: :create
    before_validation :internship_offer_week_has_spots_left?, on: :create

    def approvable?
      return false unless week.present?
      return false unless internship_offer.has_spots_left?

      true
    end

    def internship_offer_has_spots_left?
      return unless week.present?

      errors.add(:internship_offer, :has_no_spots_left) unless internship_offer.has_spots_left?
    end

    def internship_offer_week_has_spots_left?
      return if internship_offer.internship_offer_weeks.find_by(week_id: week.id).try(:has_spots_left?)
      errors.add(:week, :has_no_spots_left)
    end

    def at_most_one_application_per_student?
      return unless week.present?

      if internship_offer
          .internship_applications
          .where(week_id: week.id)
          .where(user_id: user_id)
          .count
          .positive?

        errors.add(:user_id, :duplicate)
      end
    end
  end
end
