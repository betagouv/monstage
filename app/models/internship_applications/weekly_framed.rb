module InternshipApplications
  # wraps weekly logic
  class WeeklyFramed < InternshipApplication

    belongs_to :internship_offer_week

    has_one :week, through: :internship_offer_week

    validates :internship_offer_week,
              presence: true,
              unless: :application_via_school_manager?
    before_validation :internship_offer_has_spots_left?, on: :create
    before_validation :internship_offer_week_has_spots_left?, on: :create

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

    def weekly_framed?
      true
    end
  end
end

