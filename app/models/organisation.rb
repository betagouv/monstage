class Organisation < ApplicationRecord
  include StepperProxy::Organisation

  # for ACL
  belongs_to :employer, class_name: 'User', optional: true
  has_one :internship_offer, inverse_of: :organisation, dependent: :destroy

  # linked via stepper
  has_many :internship_offers

  # call back after update
  after_update :update_internship_offers

  def update_internship_offers
    internship_offer.update_from_organisation if internship_offer
  end

  def from_api?
    false
  end
end
