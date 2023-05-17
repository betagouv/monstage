# frozen_string_literal: true

require 'sti_preload'
class PracticalInfo < ApplicationRecord
  include StepperProxy::PracticalInfo
  include StiPreload

  # for ACL
  belongs_to :employer, class_name: 'User'

  # Relation
  belongs_to :internship_offer, optional: true

  # validates :weeks, presence: true
  # has_many :hosting_info_weeks, dependent: :destroy,
  #                                          foreign_key: :hosting_info_id,
  #                                          inverse_of: :hosting_info

  # has_many :weeks, through: :hosting_info_weeks

  def from_api?; false end
  def is_fully_editable?; true end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end
end
