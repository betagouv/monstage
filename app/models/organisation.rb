class Organisation < ApplicationRecord
  include StepperProxy::Organisation

  # for ACL
  belongs_to :employer, class_name: 'User', optional: true
  has_one :internship_offer, inverse_of: :organisation, dependent: :destroy

  # linked via stepper
  has_many :internship_offers

  # call back after update
  after_update :update_internship_offer

  def update_internship_offer
    internship_offer.update_from_organisation if internship_offer
  end

  def from_api?
    false
  end

  def duplicate
    dup.tap do |new_organisation|
      new_organisation.employer = employer
      new_organisation.street = street
      new_organisation.zipcode = zipcode
      new_organisation.city = city
      new_organisation.siret = siret
      new_organisation.manual_enter = manual_enter
      new_organisation.coordinates = coordinates
      new_organisation.employer_description = employer_description
      new_organisation.employer_website = employer_website
      new_organisation.employer_name = employer_name
      new_organisation.group_id = group_id
      new_organisation.is_public = is_public
    end
  end
end
