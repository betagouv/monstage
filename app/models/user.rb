# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include UserAdmin

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :validatable, :confirmable, :trackable,
         :timeoutable

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
  validates :phone, uniqueness: { allow_blank: true },
                    format: { with: /\A\+\d{2,3}0(6|7)\d{8}\z/, message: 'Veuillez modifier le numéro de téléphone mobile' },
                    allow_blank: true

  validates :email, uniqueness: { allow_blank: true },
                    format: { with: Devise.email_regexp },
                    allow_blank: true

  validates_inclusion_of :accept_terms, in: ['1', true],
                                        message: :accept_terms,
                                        on: :create
  validate :email_or_phone
  validate :keep_email_existence, on: :update

  delegate :application, to: Rails
  delegate :routes, to: :application
  delegate :url_helpers, to: :routes

  MAX_DAILY_PHONE_RESET = 3

  def self.drh
    Users::Employer.where(email: 'drh@betagouv.fr').first
  end

  def channel
    return :phone if phone.present?

    :email
  end

  def default_search_options
    opts = {}

    opts = opts.merge(school.default_search_options) if has_relationship?(:school)
    opts = opts.merge(school_track: school_track) if has_relationship?(:school_track)
    opts = opts.merge(school_track: :troisieme_generale) if self.is_a?(Users::SchoolManagement)
    if (has_relationship?(:class_room) && class_room.troisieme_generale?) || self.is_a?(Users::SchoolManagement)
      week_ids = school.weeks
                       .where(id: Week.selectable_on_school_year.pluck(:id))
                       .pluck(:id)
                       .map(&:to_s)
      opts = opts.merge(week_ids: week_ids) if week_ids.size.positive?
    end
    opts
  end

  def has_relationship?(relationship)
    respond_to?(relationship) && self.send(relationship).present?
  end

  def missing_school_weeks?
    return false unless respond_to?(:school)
    return true if school.try(:weeks).try(:size).try(:zero?)

    Week.selectable_on_school_year # rejecting stale_weeks from last year
        .joins(:school_internship_weeks)
        .where('school_internship_weeks.school_id': school.id)
        .count
        .zero?
  end

  def missing_school?
    return true if respond_to?(:school) && school.blank?
    false
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
    return '' if gender.blank? || gender.eql?('np')
    return 'Madame' if gender.eql?('f')
    return 'Monsieur' if gender.eql?('m')

    ''
  end

  def formal_name
    "#{gender_text} #{first_name.try(:capitalize)} #{last_name.try(:capitalize)}"
  end

  def email_domain_name
    self.email.split('@').last
  end

  def archive
    anonymize(send_email: false)
  end

  def anonymize(send_email: true)
    # Remove all personal information
    email_for_job = email.dup

    fields_to_reset = {
      email: "#{SecureRandom.hex}@#{email_domain_name}" ,
      first_name: 'NA',
      last_name: 'NA',
      phone: nil,
      current_sign_in_ip: nil,
      last_sign_in_ip: nil,
      anonymized: true
    }
    update_columns(fields_to_reset)

    discard!

    unless email_for_job.blank?
      AnonymizeUserJob.perform_later(email: email_for_job) if send_email
      RemoveContactFromSyncEmailDeliveryJob.perform_later(email: email_for_job)
    end
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
    return if phone.blank?

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

  def after_confirmation
    super
  end

  rails_admin do
    list do
      scopes [:kept]
    end
  end

  def email_required?
    false
  end

  def has_no_class_room?
    class_room.nil?
  end

  def send_reconfirmation_instructions
    @reconfirmation_required = false
    unless @raw_confirmation_token
      generate_confirmation_token!
    end
    if add_email_to_phone_account?
      devise_mailer.add_email_instructions(self)
                   .deliver_later
    else
      unless @skip_confirmation_notification
        devise_mailer.update_email_instructions(self, @raw_confirmation_token, { to: unconfirmed_email })
                     .deliver_later
      end
    end
  end

  def canceled_targeted_offer_id
    canceled_targeted_offer_id = self.targeted_offer_id
    self.targeted_offer_id = nil
    save
    canceled_targeted_offer_id
  end

  def statistician? ; false end
  def ministry_statistician? ; false end
  def student? ; false end


  private

  def clean_phone
    self.phone = nil if phone == '+33'
    self.phone = phone.delete(' ') unless phone.nil?
  end

  def add_email_to_phone_account?
    phone.present? && confirmed? && email.blank?
  end

  def email_or_phone
    if email.blank? && phone.blank?
      errors.add(:email, 'Un email ou un numéro de mobile sont nécessaires.')
    end
  end

  def keep_email_existence
    if email_was.present? && email.blank?
      errors.add(
        :email,
        'Il faut conserver un email valide pour assurer la continuité du service'
      )
    end
  end
end
