class Organisation < ApplicationRecord
  include StepperProxy::Organisation

  # for ACL
  belongs_to :creator, class_name: 'User'

  has_many :employers, class_name: 'User', through: :internship_offers
  has_many :tutors, class_name: 'User', through: :internship_offers

  # linked via stepper
  has_many :internship_offers

  def from_api?
    false
  end
end
