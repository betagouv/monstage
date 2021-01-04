# wrap shared behaviour between internship offer / tutor [by stepper]
module StepperProxy
  module Tutor
    extend ActiveSupport::Concern

    included do
      validates :tutor, presence: true, unless: :from_api?
    end
  end
end
