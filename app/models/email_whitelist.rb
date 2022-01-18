# frozen_string_literal: true

require "sti_preload"
 
class EmailWhitelist < ApplicationRecord
  include StiPreload
  validates :email,
            format: { with: Devise.email_regexp },
            on: :create

  after_create :notify_account_ready
  belongs_to :user, optional: true
  after_destroy :discard_user

  private

  def discard_user
    return if user.blank?
    user.discard!
  end

end
