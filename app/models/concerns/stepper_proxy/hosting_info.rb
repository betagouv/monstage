# frozen_string_literal: true

module StepperProxy
  module HostingInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      # Validations
      validates :max_candidates,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }
      validates :max_students_per_group,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: :max_candidates ,
                                message: "Le nombre maximal d'élèves par groupe ne peut pas dépasser le nombre maximal d'élèves attendus dans l'année" }

      validate :enough_weeks

      # Relations
      belongs_to :school, optional: true # reserved to school

      def is_individual?
        max_students_per_group == 1
      end

      def init
        self.max_candidates ||= 1
        self.max_students_per_group ||= 1
      end

      def enough_weeks
        weeks = self.try(:internship_offer_weeks) || self&.hosting_info_weeks || []
        return if weeks.size.zero?
        return if (max_candidates / max_students_per_group - weeks.size) <= 0

        error_message = 'Le nombre maximal d\'élèves est trop important par ' \
                        'rapport au nombre de semaines de stage choisi. Ajoutez des ' \
                        'semaines de stage ou augmentez la taille des groupes  ' \
                        'ou diminuez le nombre de ' \
                        'stagiaires prévus.'
        errors.add(:max_candidates, error_message)
      end

      def available_weeks
        return Week.selectable_from_now_until_end_of_school_year unless respond_to?(:weeks)
        return Week.selectable_from_now_until_end_of_school_year unless persisted?
        return Week.selectable_for_school_year(school_year: SchoolYear::Floating.new(date: Date.today)) if weeks&.first.nil?

        school_year = SchoolYear::Floating.new(date: weeks.first.week_date)

        Week.selectable_on_specific_school_year(school_year: school_year)
      end
    end
  end
end
