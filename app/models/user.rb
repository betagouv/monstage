# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include UserAdmin

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable,
         authentication_keys: [:login]
  attr_writer :login
  
  include DelayedDeviseEmailSender

  before_validation :clean_phone
  after_create :send_confirmation_sms

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
  validates :phone, uniqueness: { allow_blank: true }, format: { with: /\A\+\d{2,3}(6|7)\d{8}\z/,
    message: 'Veuillez modifier le numéro de téléphone mobile' }, allow_blank: true

  validates :email, uniqueness: { allow_blank: true }, 
    format: { with: Devise.email_regexp }, allow_blank: true

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

    AnonymizeUserJob.perform_later(email: email_for_job)
    RemoveContactFromSyncEmailDeliveryJob.perform_later(email: email_for_job)
  end

  def destroy
    anonymize
  end

  def send_confirmation_sms
    return unless phone.present?
    create_phone_token
    SendSmsJob.perform_later(self)
  end

  def create_phone_token
    self.update(phone_token: sprintf('%04d',rand(10000)), 
    phone_token_validity: 1.hour.from_now)
  end

  def phone_confirmable?
    phone_token.present? && Time.now < phone_token_validity
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

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["phone = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:phone) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  private
  def login
    @login || self.username || self.email
  end

  def clean_phone
    self.phone = phone.delete(' ') unless phone.nil?
  end

  
end
