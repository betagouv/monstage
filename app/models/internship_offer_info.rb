# frozen_string_literal: true

require 'sti_preload'
class InternshipOfferInfo < ApplicationRecord
  include StepperProxy::InternshipOfferInfo
  include StiPreload

  # for ACL
  belongs_to :employer, class_name: 'User'

  # Relation
  belongs_to :internship_offer, optional: true

  def from_api?; false end
  def is_fully_editable?; true end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end
end
