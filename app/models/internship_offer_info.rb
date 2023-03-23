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

  #Duplicated methods :/
  def missing_weeks_in_the_future?
    current_week_id = Week.current.id
    internship_offer_info_weeks.map(&:week_id).none? do |week_id|
      week_id.to_i > current_week_id.to_i + 1
    end
  end

  def missing_seats?
    remaining_seats_count < 1
  end

  def requires_update?
    missing_weeks_in_the_future? || missing_seats?
  end
  # End of duplicated methods

end
