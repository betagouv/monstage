# frozen_string_literal: true

module InternshipOffers
  class WeeklyFramed < InternshipOffer
    include WeeklyFramable
    include ActiveAdminable
    # ActiveAdmin index specifics
    rails_admin do
      list do
        scopes [:not_from_api]
        field :title
        field :zipcode
        field :employer_name
        field :group
        field :is_public
        field :department
        field :created_at
      end

      export do
        field :weeks_count
        field :first_monday
        field :last_monday
      end
    end

    validates :street,
              :city,
              :tutor_name,
              :tutor_phone,
              :tutor_email,
              presence: true


    validates :max_candidates, numericality: { only_integer: true,
                                               greater_than: 0,
                                               less_than_or_equal_to: MAX_CANDIDATES_HIGHEST }
    validates :max_students_per_group, numericality: { only_integer: true,
                                                          greater_than: 0,
                                                          less_than_or_equal_to: :max_candidates,
                                                          message: "Le nombre maximal d'élèves par groupe ne peut pas dépasser le nombre maximal d'élèves attendus dans l'année" }
    after_initialize :init
    before_create :reverse_academy_by_zipcode

    # scope :ignore_max_candidates_reached, lambda {
    #   # approved_applications =
    #   where('blocked_applications_count < ?', :max_students_per_group)
    # }

    scope :fulfilled, lambda { # erroné si les applicatations count ne comporte pas que des
      applications_ar = InternshipApplication.arel_table
      offers_ar       = InternshipOffer.arel_table

      joins(:internship_applications)
        # .where(applications_ar[:aasm_state].in(%w[approved signed]))
        .merge(InternshipApplication.approved)
        .select([offers_ar[:id], applications_ar[:id].count.as('applications_count'), offers_ar[:max_candidates], offers_ar[:max_students_per_group]])
        .group(offers_ar[:id])
        .having(applications_ar[:id].count.gteq(offers_ar[:max_candidates]))
    }

    #scope :uncompleted_with_max_candidates, lambda {
    #  applications_ar = InternshipApplication.arel_table
    #  offers_ar       = InternshipOffer.arel_table
    #

    #  left_joins(:internship_applications)
    #    # .where(applications_ar[:aasm_state].in(%w[approved]))
    #    # .select([offers_ar[:id], applications_ar[:id].count, offers_ar[:max_candidates]] )
    #    .select('internship_offers.*, COUNT(internship_applications)')
    #    .group(offers_ar[:id])
    #    .having("count(internship_applications.id) < internship_offers.max_candidates")
    #    # .having(applications_ar[:id].count.lteq(offers_ar[:max_candidates]))
    #    # .having("(SELECT COUNT('internship_applications.id') FROM internship_applications WHERE 'internship_applications.aasm_state' = 'approved') < internship_offers.max_candidates")
    #    # .having("count(case when internship_applications.aasm = 'approved' then 1 else null end) < internship_offers.max_candidates")
    #}

    scope :uncompleted_with_max_candidates, lambda {
      offers_ar       = InternshipOffer.arel_table
      full_offers_ids = InternshipOffers::WeeklyFramed.fulfilled.ids

      where(offers_ar[:id].not_in(full_offers_ids))
    }


    scope :with_spot_left_weeks, lambda {
      offer_weeks_ar = InternshipOfferWeek.arel_table

      joins(:internship_offer_weeks)

    }


    # InternshipOffers::WeeklyFramed.left_joins(:internship_applications).where(applications_ar[:aasm_state].in(%w[approved])).select('internship_offers.max_candidates, internship_offers.id, COUNT(internship_applications)').group("internship_offers.id").having("count(internship_applications.id) < internship_offers.max_candidates")
    # InternshipOffers::WeeklyFramed.joins(:internship_applications).select('internship_offers.max_candidates, internship_offers.id, COUNT(internship_applications)').group("internship_offers.id").having(applications_ar[:id].count.lteq(offers_ar[:max_candidates]))

    scope :ignore_max_candidates_reached, lambda {
      applications_ar = InternshipApplication.arel_table
      offers_ar       = InternshipOffer.arel_table
      offer_weeks_ar = InternshipOfferWeek.arel_table
      ## Le nombre de blocked_application
      ## internship_offer_weeks.sum(&:blocked_applications_count)

      joins(:internship_offer_weeks, :internship_applications)
        .where(applications_ar[:aasm_state].in(%w[approved]))
        .select('internship_offers.*, count(internship_offers) as offers_count')
        .group(offers_ar[:id])
        .having(offer_weeks_ar[:blocked_applications_count].sum.lteq(offers_ar[:max_candidates]))
    }

    scope :ignore_max_candidates_reached_2, lambda {
      offer_weeks_ar = InternshipOfferWeek.arel_table
      offers_ar      = InternshipOffer.arel_table

      joins(:internship_offer_weeks)
        .select('internship_offers.*, count(internship_offers.id)')
        # .left_joins(:internship_applications)
        # .where(offer_weeks_ar[:blocked_applications_count].lt(offers_ar[:max_students_per_group]))
        # .where(offers_ar[:id].not_in(InternshipOffers::WeeklyFramed.fulfilled.pluck(:id)))
        # .group(offers_ar[:id])
    }

    scope :by_weeks, lambda { |weeks:|
      p 'Weekly framed : avant que ça pete by weeks'
      joins(:weeks).where(weeks: { id: weeks.ids })
    }

    scope :after_week, lambda { |week:|
      joins(:week).where('weeks.year > ? OR (weeks.year = ? AND weeks.number > ?)', week.year, week.year, week.number)
    }

    scope :after_current_week, lambda {
      after_week(week: Week.current)
    }

    def weeks_applicable(user:)
      weeks.from_now.available_for_student(user: user)
      #.ignore_max_candidates_reached(max_students_per_group: max_students_per_group)
    end
  end
end
