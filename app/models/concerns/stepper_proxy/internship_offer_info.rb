# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      attr_accessor :republish, :user_update
      after_initialize :init

      # Validations
      validates :title, presence: true, length: { maximum: InternshipOffer::TITLE_MAX_CHAR_COUNT }
      validates :max_candidates,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }
      validates :max_students_per_group,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: :max_candidates ,
                                message: "Le nombre maximal d'élèves par groupe ne peut pas dépasser le nombre maximal d'élèves attendus dans l'année" }
      validates :description, presence: true,
                              length: { maximum: InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT }
      validate :check_missing_seats_or_weeks, unless: :from_api? , on: :create
      validate :check_missing_seats_or_weeks, if: :user_update?, on: :update

      validate :enough_weeks

      before_validation :replicate_description_rich_text_to_raw_field, unless: :from_api?

      # Relations
      belongs_to :school, optional: true # reserved to school
      belongs_to :sector

      has_rich_text :description_rich_text

      def is_individual?
        max_students_per_group == 1
      end

      # @note some possible confusion, miss-understanding here
      #   1. Rich text was added after API
      #   2. API already exposed a "description" attributes (not rich text) [in/out]
      #     trying to upgrade description attribute was flacky
      #     because API returned description as an ActionText record.
      #   3. To avoid any circumvention (in/out) of the description
      #     we add a new description_rich_text element which is rendered when possiblee
      #   4. Bonus -> description will be used for description_tsv as template to extract keywords
      def replicate_description_rich_text_to_raw_field
        self.description = description_rich_text.to_plain_text if description_rich_text.present?
      end

      def init
        self.max_candidates ||= 1
        self.max_students_per_group ||= 1
      end

      def enough_weeks
        weekly_framed_types = [
          'InternshipOfferInfos::WeeklyFramed',
          'InternshipOffers::WeeklyFramed'
        ]
        return unless type.in? weekly_framed_types

        weeks = self.try(:internship_offer_weeks) || self&.internship_offer_info_weeks
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
        if weeks&.first.nil?
          return Week.selectable_for_school_year(
            school_year: SchoolYear::Floating.new(date: Date.today)
          )
        end

        school_year = SchoolYear::Floating.new(date: weeks.first.week_date)

        Week.selectable_on_specific_school_year(school_year: school_year)
      end
    end

    def available_weeks_when_editing
      raise 'Wrong !!' unless persisted? && respond_to?(:weeks) # temporary
      return nil unless persisted? && respond_to?(:weeks)


      school_year = SchoolYear::Floating.new(date: weeks.first.week_date)

      [Week.selectable_on_specific_school_year(school_year: school_year),
       Week.selectable_on_school_year_when_editing].map(&:to_a)
                                                   .flatten
                                                   .uniq
    end

    def weeks_class
      respond_to?(:internship_offer_weeks) ? :internship_offer_weeks : :internship_offer_info_weeks
    end

    def missing_weeks_in_the_future?
      self.send(weeks_class).map(&:week_id).all? do |week_id|
        week_id < Week.current.id.to_i + 1
      end
    end

    def check_for_weeks_in_the_future
      # return false if is_a?(InternshipOffers::Api)
      return false if published_at.nil? && republish.nil?

      if missing_weeks_in_the_future?
        errors.add(weeks_class, 'Vous devez sélectionner au moins une semaine dans le futur')
      end
    end

    def check_for_missing_seats
      if remaining_seats_count.zero?
        errors.add(:max_candidates, 'Augmentez Le nombre de places disponibles pour accueillir des élèves')
      end
    end

    def check_missing_seats_or_weeks
      return false if self.is_a?(::InternshipOfferInfo)
      return false unless published?

      check_for_weeks_in_the_future && check_for_missing_seats
    end

    def requires_update_at_toggle_time?
      return false if published?

      missing_weeks_in_the_future? || remaining_seats_count.zero?
    end

    def user_update?
      user_update == "true"
    end
  end
end
