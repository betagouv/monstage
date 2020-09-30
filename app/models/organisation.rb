class Organisation < ApplicationRecord
  include StepperProxy::Organisation
  include Nearbyable

  # for ACL
  belongs_to :employer, class_name: 'User'

  # linked via stepper
  belongs_to :internship_offer, optional: true

  def from_api?
    false
  end
end
