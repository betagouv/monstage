# wrap shared behaviour between internship offer / tutor [by stepper]
module StepperProxy
  module Tutor
    extend ActiveSupport::Concern

    included do
      validates :first_name,
                :last_name,
                :phone,
                :email,
                presence: true,
                unless: :from_api?
    end
  end
end
