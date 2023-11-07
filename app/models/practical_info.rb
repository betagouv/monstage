# frozen_string_literal: true

require 'sti_preload'
class PracticalInfo < ApplicationRecord
  include StepperProxy::PracticalInfo
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

  def daily_planning?
    daily_hours.except('samedi').values.flatten.any? { |v| !v.blank? }
  end
end
