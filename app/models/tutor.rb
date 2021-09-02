class Tutor < ApplicationRecord
  include StepperProxy::Tutor

  # for ACL
  belongs_to :employer, class_name: 'User'

  # linked via stepper
  has_many :internship_offers

  def from_api?
    false
  end
end
