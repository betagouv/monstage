# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      enum school_track: {
        troisieme_generale: 'troisieme_generale',
        troisieme_prepa_metiers: 'troisieme_prepa_metiers',
        troisieme_segpa: 'troisieme_segpa'
      }

      # Validations
      validates :title, presence: true, length: { maximum: InternshipOffer::TITLE_MAX_CHAR_COUNT }
      validates :school_track, presence: true
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
      end


      def available_weeks
        return Week.selectable_from_now_until_end_of_school_year unless respond_to?(:weeks)
        return Week.selectable_from_now_until_end_of_school_year unless persisted?
        return Week.selectable_for_school_year(school_year: SchoolYear::Floating.new(date: Date.today)) if respond_to?(:weeks) && weeks.first.nil?

        school_year = SchoolYear::Floating.new(date: self.weeks.first.week_date)

        Week.selectable_for_school_year(school_year: school_year)
      end
    end
  end
end
