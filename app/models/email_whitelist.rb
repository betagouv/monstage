# frozen_string_literal: true

require "sti_preload"

class EmailWhitelist < ApplicationRecord
  include StiPreload
  before_validation :email_downcase
  after_create :notify_account_ready,  if: :user_does_not_exist?
  after_destroy :discard_user

  belongs_to :user, optional: true

  validates :email,
            format: { with: Devise.email_regexp },
            on: :create
  private

  def discard_user
    return if user&.discarded? || fetch_user.nil?

    fetch_user.discard!
  end

  def email_downcase
    email.downcase!
  end

  def fetch_user
    user || User.find_by(email: email)
  end

  def user_does_not_exist?
    fetch_user.nil?
  end

end
