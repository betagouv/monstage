# frozen_string_literal: true

class InternshipOfferInfo < ApplicationRecord
  include StepperProxy::InternshipOfferInfo

  # for ACL
  belongs_to :employer,
             class_name: 'User',
             optional: true

  # Relation
  belongs_to :internship_offer, optional: true

  def free_date?
    false
  end

  def from_api?
    false
  end

  def is_fully_editable?
    true
  end

  def class_prefix_for_multiple_checkboxes
    'internship_offer_info'
  end
end
