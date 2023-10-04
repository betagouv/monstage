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

      attr_accessor :republish

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

      scope :shown_to_employer, lambda {
        where(hidden_duplicate: false)
      }

      scope :with_weeks_next_year, lambda {
        # beginning_of_year = SchoolYear::Current.new
        #                                        .beginning_of_period
        # beginning_of_next_year = SchoolYear::Current.new
        #                                             .next_year
        #                                             .beginning_of_period
        # from = Week.current.ahead_of_school_year_start? ? beginning_of_year : beginning_of_next_year
        # to = from + 1.year - 1.day
        # next_year_weeks_ids = Week.from_date_to_date( from: from, to: to ).ids
       
        joins(:internship_offer_weeks).where(
          internship_offer_weeks: { week_id:  Week.selectable_on_next_school_year }
        ).distinct
      }

      def having_weeks_over_several_school_years?
        next_year_first_date = SchoolYear::Current.new
                                                  .next_year
                                                  .beginning_of_period
        last_date > next_year_first_date
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

      def next_year_week_ids
        weeks.to_a
             .intersection(Week.selectable_on_next_school_year.to_a)
             .map(&:id)
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

      def split_in_two
        original_week_ids = week_ids
        print '.'
        return nil if next_year_week_ids.empty?

        internship_offer = duplicate
        internship_offer.week_ids = next_year_week_ids
        internship_offer.remaining_seats_count = max_candidates
        internship_offer.employer = employer
        if internship_offer.valid?
          internship_offer.save
        else
          raise StandardError.new "##{internship_offer.errors.full_messages} - on #{internship_offer.errors.full_messages}"
        end

        self.week_ids = original_week_ids - next_year_week_ids
        self.hidden_duplicate = true
        self.split!
        save!

        internship_offer
      end
    end
  end
end
