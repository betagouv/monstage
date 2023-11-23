# frozen_string_literal: true

module StepperProxy
  module PracticalInfo
    extend ActiveSupport::Concern

    included do
      include Nearbyable

      # Validations
      # validates :contact_phone,
      #           presence: true,
      #           unless: :from_api?,
      #           length: { minimum: 10 }
      # validates :contact_phone,
      #           unless: :from_api?,
      #           format: { with: /\A\+?[\d+\s]+\z/,
      #                     message: 'Le numéro de téléphone doit contenir des caractères chiffrés uniquement' }

      # Relations

    end
  end
end
