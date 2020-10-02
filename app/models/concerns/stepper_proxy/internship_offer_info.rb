# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      enum school_track: {
        troisieme_generale: 'troisieme_generale',
        troisieme_prepa_metier: 'troisieme_prepa_metier',
        troisieme_segpa: 'troisieme_segpa',
        bac_pro: 'bac_pro'
      }

      # Validations
      validates :title, presence: true, length: { maximum: InternshipOffer::TITLE_MAX_CHAR_COUNT }
      validates :school_track, presence: true
      validates :max_candidates, numericality: { only_integer: true,
                                                 greater_than: 0,
                                                 less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_PER_GROUP }
      validates :description, presence: true,
                              length: { maximum: InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT },
                              if: :from_api?
      validate :validate_description_rich_text_length, unless: :from_api?

      # Relations
      belongs_to :school, optional: true # reserved to school
      belongs_to :sector

      has_rich_text :description_rich_text

      def is_individual?
        max_candidates == 1
      end

      def validate_description_rich_text_length
        errors.add(:description_rich_text, :blank) if description_rich_text.to_plain_text.size.zero?
        errors.add(:description_rich_text, :too_long) if description_rich_text.to_plain_text.size > InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT
      end

      def init
        self.max_candidates ||= 1
      end
    end
  end
end
