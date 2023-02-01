# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      include Nearbyable
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

      validate :enough_weeks

      before_validation :replicate_description_rich_text_to_raw_field, unless: :from_api?

      # Relations
      belongs_to :school, optional: true # when offer is reserved to school
      belongs_to :sector

      has_many :internship_offer_info_weeks, dependent: :destroy,
                                             foreign_key: :internship_offer_info_id,
                                             inverse_of: :internship_offer_info
      has_many :weeks, through: :internship_offer_info_weeks
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
        return Week.selectable_for_school_year(school_year: SchoolYear::Floating.new(date: Date.today)) if weeks&.first.nil?

        school_year = SchoolYear::Floating.new(date: weeks.first.week_date)

        Week.selectable_on_specific_school_year(school_year: school_year)
      end

      def self.attributes_from_internship_offer(internship_offer_id:)
        internship_offer = InternshipOffers::WeeklyFramed.find_by(id: internship_offer_id)
        return {} if internship_offer.nil?

        {
          title: internship_offer.title,
          employer_name: internship_offer.employer_name,
          employer_id: internship_offer.employer_id,
          description_rich_text: (internship_offer.description_rich_text.present? ? internship_offer.description_rich_text.to_s : internship_offer.description),
          max_candidates: internship_offer.max_candidates,
          max_students_per_group: internship_offer.max_students_per_group,
          description: internship_offer.description,
          sector_id: internship_offer.sector.id,
          school_id: internship_offer&.school&.id,
          street: internship_offer.street,
          city: internship_offer.city,
          zipcode: internship_offer.zipcode,
          weekly_hours: internship_offer.weekly_hours,
          new_daily_hours: internship_offer.new_daily_hours,
          daily_lunch_break: internship_offer.daily_lunch_break,
          weekly_lunch_break: internship_offer.weekly_lunch_break,
          coordinates: internship_offer.coordinates,
          week_ids: internship_offer.week_ids
        }
      end

      def synchronize(internship_offer)
        parameters = InternshipOffers::WeeklyFramed.preprocess_internship_offer_info_to_params(self)
                                                   .merge(internship_offer_info_id: id)
        internship_offer.update(parameters)
        internship_offer
      end
    end
  end
end
