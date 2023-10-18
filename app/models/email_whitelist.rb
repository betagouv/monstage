# frozen_string_literal: true


class EmailWhitelist < ApplicationRecord
  before_validation :email_downcase
  after_create :notify_account_ready,  if: :user_does_not_exist?
  after_destroy :discard_user

  belongs_to :user, optional: true

  validates :email,
            format: { with: Devise.email_regexp },
            on: :create

  def self.destroy_by(email: )
    email_whitelist = find_by(email: email)
    return if email_whitelist.nil?

    email_whitelist.destroy
  end

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
