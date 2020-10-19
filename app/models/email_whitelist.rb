# frozen_string_literal: true

class EmailWhitelist < ApplicationRecord
  validates :email, format: { with: Devise.email_regexp }, on: :create
  validates :zipcode, inclusion: { in: Department::MAP.keys }

  after_create :notify_account_ready
  belongs_to :user, optional: true
  after_destroy :discard_user

  rails_admin do
    list do
      field :id
      field :email
      field :zipcode
    end
    show do
      field :id
      field :email
      field :zipcode
    end
    edit do
      field :email
      field :zipcode
    end
  end

  private

  def discard_user
    return if user.blank?
    user.discard!
  end

  def notify_account_ready
    EmailWhitelistMailer.notify_ready(recipient_email: email)
                        .deliver_later
  end
end
