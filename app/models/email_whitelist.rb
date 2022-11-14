# frozen_string_literal: true

require "sti_preload"

class EmailWhitelist < ApplicationRecord
  include StiPreload
  before_validation :email_downcase
  after_create :notify_account_ready
  after_destroy :discard_user

  belongs_to :user, optional: true

  validates :email,
            format: { with: Devise.email_regexp },
            on: :create
  private

  def discard_user
    return if user.blank?

    user.discard!
  end

  def email_downcase
    email.downcase!
  end

end
