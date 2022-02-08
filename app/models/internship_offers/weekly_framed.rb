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

    #---------------------
    # fullfilled scope isolates those offers that have reached max_candidates
    #---------------------
    scope :fulfilled, lambda {
      offers_ar      = InternshipOffer.arel_table
      offer_weeks_ar = InternshipOfferWeek.arel_table

      joins(:internship_offer_weeks)
        .select([offer_weeks_ar[:blocked_applications_count].sum, offers_ar[:id],offers_ar[:max_candidates]])
        .group(offers_ar[:id])
        .having(offer_weeks_ar[:blocked_applications_count].sum.gteq(offers_ar[:max_candidates]))
    }

    scope :uncompleted_with_max_candidates, lambda {
      offers_ar       = InternshipOffer.arel_table
      full_offers_ids = InternshipOffers::WeeklyFramed.fulfilled.ids

      where(offers_ar[:id].not_in(full_offers_ids))
    }

    scope :by_weeks, lambda { |weeks:|
      joins(:weeks).where(weeks: { id: weeks.ids })
    }

    scope :after_week, lambda { |week:|
      joins(:week).where('weeks.year > ? OR (weeks.year = ? AND weeks.number > ?)', week.year, week.year, week.number)
    }

    scope :after_current_week, lambda {
      after_week(week: Week.current)
    }

    # def approved_applications_count
    #   internship_offer_weeks.pluck(:blocked_applications_count).sum
    # end

    def weeks_applicable(user:)
      weeks.from_now.available_for_student(user: user)
    end
  end
end
