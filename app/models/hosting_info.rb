# frozen_string_literal: true

class HostingInfo < ApplicationRecord
  include StepperProxy::HostingInfo

  # for ACL
  belongs_to :employer, class_name: 'User'

  # Relation
  belongs_to :internship_offer, optional: true

  validates :weeks, presence: true
  validate :enough_weeks

  has_many :hosting_info_weeks, dependent: :destroy,
                                           foreign_key: :hosting_info_id,
                                           inverse_of: :hosting_info

  has_many :weeks, through: :hosting_info_weeks

  def from_api?; false end
  def is_fully_editable?; true end
end