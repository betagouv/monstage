# frozen_string_literal: true

# application from student to internship_offer ; linked with weeks
require 'sti_preload'
class InternshipApplication < ApplicationRecord
  include StiPreload
  include AASM
  include Rails.application.routes.url_helpers
  PAGE_SIZE = 10
  EXPIRATION_DURATION = 15.days
  EXTENDED_DURATION = 15.days
  MAGIC_LINK_EXPIRATION_DELAY = 5.days
  RECEIVED_STATES = %w[submitted read_by_employer examined expired transfered]
  PENDING_STATES = RECEIVED_STATES + %w[validated_by_employer] - %w[expired]
  REJECTED_STATES = %w[rejected canceled_by_employer canceled_by_student canceled_by_student_confirmation]
  APPROVED_STATES = %w[approved validated_by_employer]
  ORDERED_STATES_INDEX = %w[
    drafted
    expired
    canceled_by_student_confirmation
    canceled_by_student
    rejected
    expired_by_student
    canceled_by_employer
    submitted
    read_by_employer
    transfered
    examined
    validated_by_employer
    approved ]

  attr_accessor :sgid

  belongs_to :internship_offer, polymorphic: true
  # has_many :internship_agreements
  belongs_to :student, class_name: 'Users::Student',
                       foreign_key: 'user_id'
  has_one :internship_agreement
  # has_many :internship_applications

  delegate :update_all_counters, to: :internship_application_counter_hook
  delegate :name, to: :student, prefix: true
  delegate :employer, to: :internship_offer
  delegate :remaining_seats_count, to: :internship_offer

  after_save :update_all_counters
  accepts_nested_attributes_for :student, update_only: true

  has_rich_text :approved_message
  has_rich_text :rejected_message
  has_rich_text :examined_message
  has_rich_text :canceled_by_employer_message
  has_rich_text :canceled_by_student_message
  has_rich_text :motivation

  paginates_per PAGE_SIZE

  # Validations
  validate :check_contact_uniqueness

  # Callbacks
  after_create :update_student_profile

  #
  # Triggers scopes (used for transactional mails)
  #

  # reminders after 7 days, 14 days and none afterwards
  scope :remindable, lambda {
    passed_sumitted = examined.where(submitted_at: 16.days.ago..7.days.ago)
                              .where(canceled_at: nil)
                              .or(submitted.where(submitted_at: 16.days.ago..7.days.ago)
                                           .where(canceled_at: nil))
    starting = passed_sumitted.where('pending_reminder_sent_at is null')
    current  = passed_sumitted.where('pending_reminder_sent_at < :date', date: 7.days.ago)
    starting.or(current)
  }

  scope :expiration_not_extended_states, lambda {
    where(aasm_state: %w[submitted read_by_employer])
  }

  scope :expirable, lambda {
    simple_duration = InternshipApplication::EXPIRATION_DURATION
    extended_duration = simple_duration + InternshipApplication::EXTENDED_DURATION
    expiration_not_extended_states.where('submitted_at < :date', date: simple_duration.ago)
      .or(examined.where('submitted_at < :date', date: extended_duration.ago))
  }

  scope :filtering_discarded_students, lambda {
    joins(:student).where(student: {discarded_at: nil})
  }

  #
  # Ordering scopes (used for ordering in ui)
  #
  # TODO remove column convention_signed_at
  scope :order_by_aasm_state, lambda {
    select("#{table_name}.*")
      .select(%(
      CASE
        WHEN aasm_state = 'convention_signed' THEN 0
        WHEN aasm_state = 'drafted' THEN 1
        WHEN aasm_state = 'approved' THEN 2
        WHEN aasm_state = 'submitted' THEN 3
        WHEN aasm_state = 'rejected' THEN 4
        WHEN aasm_state = 'examined' THEN 5
        ELSE 0
      END as orderable_aasm_state
    ))
      .order('orderable_aasm_state')
  }

  scope :order_by_aasm_state_for_student, lambda {
    select("#{table_name}.*")
      .select(%(
      CASE
        WHEN aasm_state = 'validated_by_employer' THEN 0
        ELSE 1
      END as orderable_aasm_state
    ))
      .order('orderable_aasm_state')
  }


  scope :no_date_index, lambda {
    where.not(aasm_state: [:drafted])
    .includes(
      :student,
      :internship_offer
    ).default_order
  }

  scope :with_date_index, ->(internship_offer:){
    joins(internship_offer_week: :internship_offer)
    .where('internship_offers.id = ?', internship_offer.id)
    .where.not('internship_applications.aasm_state = ?', 'drafted')
    .includes(:student, :internship_offer)
  }

  scope :through_teacher, ->(teacher:) {
    joins(student: :class_room).where('users.class_room_id = ?', teacher.class_room_id)
  }

  scope :with_active_students, lambda{
    joins(:student).where('users.discarded_at is null')
  }

  scope :not_drafted, ->{ where.not(aasm_state: 'drafted') }

  scope :approved_or_signed, lambda {
    applications = InternshipApplication.arel_table
    where(applications[:aasm_state].in(['approved', 'signed']))
  }

  scope :pending_for_employers, lambda {
    applications = InternshipApplication.arel_table
    where(applications[:aasm_state].in(['submitted', 'read_by_employer']))
  }

  scope :current_school_year, lambda {
    where(created_at: SchoolYear::Current.new.beginning_of_period..SchoolYear::Current.new.end_of_period)
  }


  #
  # Other stuffs
  #
  scope :default_order, ->{ order(updated_at: :desc) }
  scope :for_user, ->(user:) { where(user_id: user.id) }
  scope :not_by_id, ->(id:) { where.not(id: id) }

  scope :weekly_framed, -> { where(type: InternshipApplications::WeeklyFramed.name) }

  # add an additional delay when sending email using richtext
  # sometimes email was sent before action_texts_rich_text was persisted
  def deliver_later_with_additional_delay
    yield.deliver_later(wait: 1.second)
  end


  aasm do
    state :drafted, initial: true
    state :submitted,
          :read_by_employer,
          :examined,
          :transfered,
          :validated_by_employer,
          :approved,
          :rejected,
          :expired,
          :expired_by_student,
          :canceled_by_employer,
          :canceled_by_student,
          :canceled_by_student_confirmation

    event :submit do
      transitions from: :drafted,
                  to: :submitted,
                  after: proc { |*_args|
        update!("submitted_at": Time.now.utc)
        deliver_later_with_additional_delay do
          EmployerMailer.internship_application_submitted_email(internship_application: self)
        end
        setSingleApplicationReminderJobs
      }
    end

    event :read do
      transitions from: :submitted, to: :read_by_employer,
                  after: proc { |*_args|
        update!("read_at": Time.now.utc)
      }
    end

    event :examine do
      transitions from: %i[submitted read_by_employer],
                  to: :examined,
                  after: proc { |*_args|
        update!("examined_at": Time.now.utc)
        deliver_later_with_additional_delay do
          StudentMailer.internship_application_examined_email(internship_application: self)
        end
      }
    end

    event :transfer do
      transitions from: %i[submitted read_by_employer examined],
                  to: :transfered,
                  after: proc { |*_args|
                    update!("transfered_at": Time.now.utc)
      }
    end

    event :employer_validate do
      from_states = %i[read_by_employer
                       submitted
                       examined
                       transfered
                       cancel_by_employer
                       rejected]
      transitions from: from_states,
                  to: :validated_by_employer,
                  after: proc { |*_args|
                    update!("validated_by_employer_at": Time.now.utc, aasm_state: :validated_by_employer)
                    self.reload
                    after_employer_validation_notifications
                    CancelValidatedInternshipApplicationJob.set(wait: 15.days).perform_later(internship_application_id: id)
                  }
    end

    event :approve do
      transitions from: %i[validated_by_employer],
                  to: :approved,
                  after: proc { |*_args|
                    update!("approved_at": Time.now.utc)
                    student_approval_notifications
                    cancel_all_pending_applications
                  }
    end

    event :cancel_by_student_confirmation do
      from_states = %i[submitted
                       read_by_employer
                       examined
                       transfered
                       validated_by_employer ]
      transitions from: from_states,
                  to: :canceled_by_student_confirmation,
                  after: proc { |*_args|
                    if employer_aware_states.include?(self.aasm_state)
                      # Employer need to be notified
                      EmployerMailer.internship_application_approved_for_an_other_internship_offer(internship_application: self).deliver_later
                    end
                  }
    end

    event :reject do
      from_states = %i[read_by_employer
                       submitted
                       examined
                       transfered
                       validated_by_employer ]
      transitions from: from_states,
                  to: :rejected,
                  after: proc { |*_args|
                           update!("rejected_at": Time.now.utc)
                           if student.email.present?
                             deliver_later_with_additional_delay do
                               StudentMailer.internship_application_rejected_email(internship_application: self)
                             end
                           end
                         }
    end

    event :cancel_by_employer do
      from_states = %i[drafted
                       submitted
                       read_by_employer
                       examined
                       transfered
                       validated_by_employer
                       approved ]
      transitions from: from_states,
                  to: :canceled_by_employer,
                  after: proc { |*_args|
                           update!("canceled_at": Time.now.utc)
                           if student.email.present?
                              deliver_later_with_additional_delay do
                                StudentMailer.internship_application_canceled_by_employer_email(internship_application: self)
                              end
                           end
                           self.internship_agreement&.destroy
                         }
    end

    event :cancel_by_student do
      from_states = %i[submitted
                       read_by_employer
                       examined
                       validated_by_employer
                       approved]
      transitions from: from_states,
                  to: :canceled_by_student,
                  after: proc { |*_args|
                           update!("canceled_at": Time.now.utc)
                           deliver_later_with_additional_delay do
                             EmployerMailer.internship_application_canceled_by_student_email(
                               internship_application: self
                             )
                           end
                           self.internship_agreement&.destroy
                         }
    end

    event :expire do
      transitions from: %i[submitted  read_by_employer examined validated_by_employer],
                  to: :expired,
                  after: proc { |*_args|
        update!(expired_at: Time.now.utc)
      }
    end

    event :expire_by_student do
      transitions from: %i[validated_by_employer read_by_employer examined submitted drafted],
                  to: :expired_by_student,
                  after: proc { |*_args|
        update!(expired_at: Time.now.utc)
      }
    end
  end

  def state_index
    ORDERED_STATES_INDEX.index(aasm_state)
  end

  def self.best_state(applications)
    return nil if applications.empty?

    max_ranking_state = applications.map(&:state_index).max
    ORDERED_STATES_INDEX[max_ranking_state]
  end

  def setSingleApplicationReminderJobs
    if student.internship_applications.count == 1
      Triggered::SingleApplicationReminderJob.set(wait: 2.days).perform_later(student.id)
      Triggered::SingleApplicationSecondReminderJob.set(wait: 5.days).perform_later(student.id)
    end
  end

  def student_approval_notifications
    main_teacher = student.main_teacher
    arg_hash = {
      internship_application: self,
      main_teacher: main_teacher
    }
    school_manager_presence = student&.school&.school_manager&.present?
    if type == "InternshipApplications::WeeklyFramed" && school_manager_presence
      create_agreement if employer.agreement_signatorable?
      if main_teacher.present?
        deliver_later_with_additional_delay do
          MainTeacherMailer.internship_application_approved_with_agreement_email(**arg_hash)
        end
      end
    elsif main_teacher.present?
      deliver_later_with_additional_delay do
        MainTeacherMailer.internship_application_approved_with_no_agreement_email(**arg_hash)
      end
    end
  end

  def self.from_sgid(sgid)
    GlobalID::Locator.locate_signed( sgid)
  end

  def self.with_employer_explanations_states
    %w[rejected canceled_by_employer examined]
  end

  def after_employer_validation_notifications
    if type == "InternshipApplications::WeeklyFramed" && student.main_teacher.present?
      deliver_later_with_additional_delay do
        MainTeacherMailer.internship_application_validated_by_employer_email(self)
      end
    end
    if student.email.present?
      deliver_later_with_additional_delay do
        StudentMailer.internship_application_validated_by_employer_email(internship_application: self)
      end
    end
    SendSmsStudentValidatedApplicationJob.perform_later(internship_application_id: id)
  end

  def generate_token
    return if access_token.present?
    self.access_token = SecureRandom.hex(10)
    self.save
  end

  def create_agreement
    return unless internship_agreement_creation_allowed?

    agreement = Builders::InternshipAgreementBuilder.new(user: Users::God.new)
                                                    .new_from_application(self)
    agreement.skip_validations_for_system = true
    agreement.save!

    EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    ).deliver_later
  end

  def internship_application_counter_hook
    case self
    when InternshipApplications::WeeklyFramed
      InternshipApplicationCountersHooks::WeeklyFramed.new(internship_application: self)
    else
      raise 'can not process stats for this kind of internship_application'
    end
  end

  def internship_application_aasm_message_builder(aasm_target:)
    case self
    when InternshipApplications::WeeklyFramed
      InternshipApplicationAasmMessageBuilders::WeeklyFramed.new(internship_application: self, aasm_target: aasm_target)
    else
      raise 'can not build aasm message for this kind of internship_application'
    end
  end

  def student_is_male?
    student.gender == 'm'
  end

  def student_is_female?
    student.gender == 'f'
  end

  def application_via_school_manager?
    internship_offer&.school_id
  end

  def max_dunning_letter_count_reached?
    dunning_letter_count >= 1
  end

  def anonymize
    motivation.try(:delete)
    return unless student_phone || student_email

    self.student_phone = nil
    self.student_email = nil
    self.save
  end

  def short_target_url(sgid = nil)
    options = Rails.configuration.action_mailer.default_url_options
    target = dashboard_students_internship_application_url(
                student_id: student.id,
                id: id,
                **options
             )
    target = "#{target}?student_id=#{student.id}"
    target = "#{target}&sgid=#{sgid}" if sgid
    UrlShrinker.short_url(url: target, user_id: student.id)
  end

  def sgid_short_url
    sgid = student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
    short_target_url(sgid)
  end

  # Used for prettier links in rails_admin
  def title
    "Candidature de " + student_name
  end

  def cancel_all_pending_applications
    student.internship_applications.where(aasm_state: InternshipApplication::PENDING_STATES).each do |application|
      application.cancel_by_student_confirmation! unless application == self
    end
  end

  def filter_notified_emails
    original_employer = internship_offer.employer
    return employer.email unless employer.employer_like?
    return employer.email if employer.team.not_exists?

    potential_employers = original_employer.team.db_members
    emails = potential_employers.map do |potential_employer|
      should_notify?(potential_employer) ? potential_employer.email : nil
    end
    emails.compact
  end

  rails_admin do
    weight 14
    navigation_label 'Offres'

    list do
      field :id
      field :student
      field :internship_offer
      field :aasm_state, :state
      field :week do
        pretty_value do
          bindings[:object].internship_offer.is_a?(InternshipOffers::WeeklyFramed) ? value : ""
        end
      end
    end
  end

  def presenter(user)
    @presenter ||= Presenters::InternshipApplication.new(self, user)
  end

  private

  def should_notify?(employer)
    internship_offer.internship_offer_area
                    .area_notifications
                    .find_by(user_id: employer.id)
                    .notify
  end

  def internship_agreement_creation_allowed?
    return false unless student.school&.school_manager&.email
    return false unless internship_offer.employer.employer_like?

    true
  end

  def employer_aware_states
    %w[read_by_employer examined validated_by_employer]
  end

  def check_contact_uniqueness
    if student_email && User.where.not(id: student.id).exists?(email: student_email)
      errors.add(:student_email, 'Cet email est déjà utilisé')
    end

    if student_phone && User.where.not(id: student.id).exists?(phone: "+33#{student_phone}")
      errors.add(:student_phone, 'Ce numéro de téléphone est déjà utilisé')
    end
  end

  def update_student_profile
    student.update( 
      phone: student.phone || "+33#{student_phone}",
      email: student.email || student_email
    )
  end
end
