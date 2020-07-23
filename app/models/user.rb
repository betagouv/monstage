# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include UserAdmin

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  include DelayedDeviseEmailSender

  before_validation :clean_phone
  after_create :send_sms_token

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
  validates :phone, uniqueness: { allow_blank: true }, format: { with: /\A\+\d{2,3}0(6|7)\d{8}\z/,
                                                                 message: 'Veuillez modifier le numéro de téléphone mobile' }, allow_blank: true

  validates :email, uniqueness: { allow_blank: true },
                    format: { with: Devise.email_regexp }, allow_blank: true

  validates_inclusion_of :accept_terms, in: ['1', true],
                                        message: :accept_terms,
                                        on: :create
  validate :email_or_phone

  delegate :application, to: Rails
  delegate :routes, to: :application
  delegate :url_helpers, to: :routes

  delegate :middle_school?, to: :class_room, allow_nil: true
  delegate :high_school?, to: :class_room, allow_nil: true

  MAX_DAILY_PHONE_RESET = 3

  def self.drh
    Users::Employer.where(email: 'drh@betagouv.fr').first
  end

  def channel
    return :phone if phone.present?
    return :email if email.present?

    nil
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

    AnonymizeUserJob.perform_later(email: email_for_job)
    RemoveContactFromSyncEmailDeliveryJob.perform_later(email: email_for_job)
  end

  def destroy
    anonymize
  end

  def reset_password_by_phone
    if phone_password_reset_count < MAX_DAILY_PHONE_RESET || last_phone_password_reset < 1.day.ago
      send_sms_token
      update(phone_password_reset_count: phone_password_reset_count + 1,
             last_phone_password_reset: Time.now)
    end
  end

  def formatted_phone
    phone[0..4].gsub('0', '') + phone[5..]
  end

  def send_sms_token
    return unless phone.present?

    create_phone_token
    SendSmsJob.perform_later(self)
  end

  def create_phone_token
    update(phone_token: format('%04d', rand(10_000)),
           phone_token_validity: 1.hour.from_now)
  end

  def phone_confirmable?
    phone_token.present? && Time.now < phone_token_validity
  end

  def confirm_by_phone!
    update(phone_token: nil,
           phone_token_validity: nil,
           confirmed_at: Time.now,
           phone_password_reset_count: 0)
  end

  def check_phone_token?(token)
    phone_confirmable? && phone_token == token
  end

  # in case of an email update, former one has to be withdrawn
  def after_confirmation
    super
    AddContactToSyncEmailDeliveryJob.perform_later(user: self)

    return if email_previous_change.try(:first).nil?

    RemoveContactFromSyncEmailDeliveryJob.perform_later(
      email: email_previous_change.first
    )
  end

  rails_admin do
    list do
      scopes [:kept]
    end
  end

  def email_required?
    false
  end

  private

  def clean_phone
    self.phone = phone.delete(' ') unless phone.nil?
  end

  def email_or_phone
    if email.blank? && phone.blank?
      errors.add(:email, 'Un email ou un téléphone mobile est nécessaire.')
      errors.add(:phone, 'Un email ou un téléphone mobile est nécessaire.')
    end
  end
end
