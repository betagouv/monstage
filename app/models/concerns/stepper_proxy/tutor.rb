# wrap shared behaviour between internship offer / tutor [by stepper]
module StepperProxy
  module Tutor
    extend ActiveSupport::Concern

    included do
      validates :tutor_name,
                :tutor_phone,
                :tutor_email,
                presence: true,
                unless: :from_api?
    end
  end
end
