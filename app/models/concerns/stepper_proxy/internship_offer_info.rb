# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      attr_accessor :republish, :user_update
      after_initialize :init

      # Validations as they should be for new and older offers
      validates :title, presence: true, length: { maximum: InternshipOffer::TITLE_MAX_CHAR_COUNT }


      validates :description, presence: true,
                              length: { maximum: InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT }


      
      before_validation :replicate_description_rich_text_to_raw_field, unless: :from_api?

      # Relations
      belongs_to :sector

      has_rich_text :description_rich_text

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
      end
    end
  end
end
