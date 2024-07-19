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

      # Relations
      belongs_to :sector

      # has_rich_text :description_rich_text

      def init
      end
    end
  end
end
