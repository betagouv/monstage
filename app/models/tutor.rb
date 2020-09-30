class Tutor < ApplicationRecord
  include StepperProxy::Tutor

  # for ACL
  belongs_to :employer, class_name: 'User'

  # linked via stepper
  belongs_to :internship_offer, optional: true

  def from_api?
    false
  end
end
