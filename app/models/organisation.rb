class Organisation < ApplicationRecord
  include StepperProxy::Organisation

  # for ACL
  belongs_to :employer, class_name: 'User'

  has_many :employers, class_name: 'User', through: :internship_offers
  has_many :tutors, class_name: 'User', through: :internship_offers

  # linked via stepper
  belongs_to :internship_offer, optional: true

  def from_api?
    false
  end
end
