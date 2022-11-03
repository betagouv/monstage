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
          .where.not(id: InternshipApplication.where(user_id: user.id).map(&:internship_offer_id))
      }

      scope :fulfilled, lambda {
        applications_ar = InternshipApplication.arel_table
        offers_ar       = InternshipOffer.arel_table

        joins(internship_offer_weeks: :internship_applications)
          .where(applications_ar[:aasm_state].in(%w[approved signed]))
          .select([offers_ar[:id], applications_ar[:id].count.as('applications_count'), offers_ar[:max_candidates], offers_ar[:max_students_per_group]])
          .group(offers_ar[:id])
          .having(applications_ar[:id].count.gteq(offers_ar[:max_candidates]))
      }

      scope :uncompleted, lambda {
        offers_ar       = InternshipOffer.arel_table
        full_offers_ids = InternshipOffers::WeeklyFramed.fulfilled.pluck(:id)

        where(offers_ar[:id].not_in(full_offers_ids))
      }

      # Retourner toutes les offres qui ont au moins une semaine de libre ???
      scope :ignore_max_candidates_reached, lambda { 
        offer_weeks_ar = InternshipOfferWeek.arel_table
        offers_ar      = InternshipOffer.arel_table

        joins(:internship_offer_weeks)
          .select(offers_ar[Arel.star], offers_ar[:id].count)
          .left_joins(:internship_applications)
          .where(offer_weeks_ar[:blocked_applications_count].lt(offers_ar[:max_students_per_group]))
          .where(offers_ar[:id].not_in(InternshipOffers::WeeklyFramed.fulfilled.pluck(:id)))
          .group(offers_ar[:id])
      }

      
      # scope :ignore_max_internship_offer_weeks_reached, lambda {
      #   where('internship_offer_weeks_count > blocked_weeks_count')
      # }

      scope :specific_school_year, lambda { |school_year:|
        week_ids = Week.weeks_of_school_year(school_year: school_year).pluck(:id)

        joins(:internship_offer_weeks)
          .where('internship_offer_weeks.week_id in (?)', week_ids)
      }

      def weekly?
        true
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
