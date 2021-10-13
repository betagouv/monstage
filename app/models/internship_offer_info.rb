# frozen_string_literal: true

class InternshipOfferInfo < ApplicationRecord
  include StepperProxy::InternshipOfferInfo

  # for ACL
  belongs_to :employer, class_name: 'User'

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

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end
end
