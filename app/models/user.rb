# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include UserAdmin

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  include DelayedDeviseEmailSender

  after_save :add_to_contacts, if: :saved_change_to_confirmed_at?

  # school_managements includes different roles
  # 1. school_manager should register with ac-xxx.fr email
  # 2.3.4. can register
  enum role: {
    school_manager: 'school_manager',
    teacher: 'teacher',
    main_teacher: 'main_teacher',
    other: 'other'
  }

  validates :first_name, :last_name,
            presence: true

  validates :email, format: { with: Devise.email_regexp }, on: :create

  validates_inclusion_of :accept_terms, in: ['1', true],
                                        message: :accept_terms,
                                        on: :create

  delegate :application, to: Rails
  delegate :routes, to: :application
  delegate :url_helpers, to: :routes

  def self.drh
    Users::Employer.where(email: 'drh@betagouv.fr').first
  end

  def missing_school_weeks?
    return false unless respond_to?(:school)

    try(:school)
      .try(:weeks)
      .try(:size)
      .try(:zero?)
  end

  def to_s
    "logged in as : #{type}[##{id}]"
  end

  def name
    "#{first_name.try(:capitalize)} #{last_name.try(:capitalize)}"
  end

  def after_sign_in_path
    custom_dashboard_path
  end

  def dashboard_name
    'Mon tableau'
  end

  def account_link_name
    'Mon profil'
  end

  def default_account_section
    'identity'
  end

  def custom_dashboard_paths
    [
      custom_dashboard_path
    ]
  end

  def gender_text
    return '' if gender.blank?
    return 'Madame' if gender.eql?('f')
    return 'Monsieur' if gender.eql?('m')

    ''
  end

  def formal_name
    "#{gender_text} #{first_name.try(:upcase)} #{last_name.try(:upcase)}"
  end

  def anonymize
    # Remove all personal information
    email_for_job = email.dup

    fields_to_reset = {
      email: SecureRandom.hex,
      first_name: 'NA',
      last_name: 'NA',
      phone: nil,
      current_sign_in_ip: nil,
      last_sign_in_ip: nil
    }
    update_columns(fields_to_reset)

    discard!

    AnonymizeUserJob.perform_later(email_for_job)
    RemoveContactFromSyncEmailDeliveryJob.perform_later(email: email_for_job)
  end

  def destroy
    anonymize
  end

  def add_to_contacts
    return if email_previous_change.blank? ||
              Rails.env == 'development'

    AddContactToSyncEmailDeliveryJob.perform_later(user: self)
  end

  def after_confirmation
    super
    return if email_previous_change.try(:first).nil? ||
              Rails.env == 'development'

    RemoveContactFromSyncEmailDeliveryJob.perform_later(
      email: email_previous_change.first
    )
  end

  rails_admin do
    list do
      scopes [:kept]
    end
  end
end
