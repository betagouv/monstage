module InternshipOffers
  # wraps weekly logic
  module WeeklyFramable
    extend ActiveSupport::Concern

    included do
      validates :weeks, presence: true

      has_many :internship_offer_weeks, dependent: :destroy,
                                        foreign_key: :internship_offer_id,
                                        inverse_of: :internship_offer

      has_many :weeks, through: :internship_offer_weeks

      scope :ignore_already_applied, lambda { |user:|
        where(type: ['InternshipOffers::WeeklyFramed', 'InternshipOffers::Api'])
          .where.not(id: joins(internship_offer_weeks: :internship_applications)
                      .merge(InternshipApplication.where(user_id: user.id)))
      }

      scope :ignore_max_candidates_reached, lambda {
        joins(:internship_offer_weeks)
          .where('internship_offer_weeks.blocked_applications_count < internship_offers.max_candidates')
      }

      scope :ignore_max_internship_offer_weeks_reached, lambda {
        where('internship_offer_weeks_count > blocked_weeks_count')
      }

      scope :specific_school_year, lambda { |school_year:|
        week_ids = Week.weeks_of_school_year(school_year: school_year).pluck(:id)

        joins(:internship_offer_weeks)
        .where('internship_offer_weeks.week_id in (?)', week_ids)
      }

      def weekly?
        true
      end

      def free_date?
        false
      end

      def weeks_count
        internship_offer_weeks.count
      end

      def first_monday
        I18n.l internship_offer_weeks.first.week.week_date,
               format: Week::WEEK_DATE_FORMAT
      end

      def last_monday
        I18n.l internship_offer_weeks.last.week.week_date,
               format: Week::WEEK_DATE_FORMAT
      end

      def has_spots_left?
        internship_offer_weeks.any?(&:has_spots_left?)
      end

      def is_fully_editable?
        internship_applications.empty?
      end

      #
      # callbacks
      #
      def sync_first_and_last_date
        ordered_weeks = weeks.sort { |a, b| [a.year, a.number] <=> [b.year, b.number] }
        first_week = ordered_weeks.first
        last_week = ordered_weeks.last
        self.first_date = first_week.week_date.beginning_of_week
        self.last_date = last_week.week_date.end_of_week
      end

      #
      # inherited
      #
      def duplicate
        internship_offer = super
        internship_offer.week_ids = week_ids
        internship_offer
      end
    end
  end
end
