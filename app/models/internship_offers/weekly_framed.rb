module InternshipOffers
  # wraps weekly logic
  module WeeklyFramed
    extend ActiveSupport::Concern

    included do
      validates :weeks, presence: true

      has_many :internship_offer_weeks, dependent: :destroy,
                                        foreign_key: :internship_offer_id,
                                        inverse_of: :internship_offer

      has_many :weeks, through: :internship_offer_weeks

      def has_spots_left?
        internship_offer_weeks.any?(&:has_spots_left?)
      end

      def is_fully_editable?
        internship_applications.empty?
      end

      def duplicate
        internship_offer = super
        internship_offer.week_ids = week_ids
        internship_offer
      end

      scope :ignore_max_candidates_reached, lambda {
        joins(:internship_offer_weeks)
          .where('internship_offer_weeks.blocked_applications_count < internship_offers.max_candidates')
      }

      scope :ignore_max_internship_offer_weeks_reached, lambda {
        where('internship_offer_weeks_count > blocked_weeks_count')
      }

      scope :internship_offers_overlaping_school_weeks, lambda { |weeks:|
        by_weeks(weeks: weeks)
      }
    end
  end
end

