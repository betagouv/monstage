# frozen_string_literal: true

require 'sti_preload'
class InternshipOfferInfo < ApplicationRecord
  include StepperProxy::InternshipOfferInfo
  include StiPreload

  validates :manual_enter, presence: true

  # for ACL
  belongs_to :employer, class_name: 'User'

  # Relation
  has_one :internship_offer

  def from_api?; false end
  def is_fully_editable?; true end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end
end
