# frozen_string_literal: true

# application from student to internship_offer ; linked with weeks
class InternshipApplication < ApplicationRecord
  include AASM
  PAGE_SIZE = 10

  belongs_to :internship_offer, polymorphic: true

  belongs_to :student, class_name: 'Users::Student',
                       foreign_key: 'user_id'
  has_one :internship_agreement


  delegate :update_all_counters, to: :internship_application_counter_hook
  delegate :name, to: :student, prefix: true

  after_save :update_all_counters

  accepts_nested_attributes_for :student, update_only: true

  has_rich_text :approved_message
  has_rich_text :rejected_message
  has_rich_text :canceled_by_employer_message
  has_rich_text :canceled_by_student_message
  has_rich_text :motivation

  paginates_per PAGE_SIZE

  #
  # Triggers scopes (used for transactional mails)
  #
  scope :not_reminded, lambda {
    where(pending_reminder_sent_at: nil)
  }

  scope :remindable, lambda {
    submitted.not_reminded
             .where(submitted_at: 15.days.ago..7.days.ago)
             .where(canceled_at: nil)
  }

  scope :expirable, lambda {
    submitted.where('submitted_at < :date', date: 15.days.ago)
  }

  #
  # Ordering scopes (used for ordering in ui)
  #
  scope :order_by_aasm_state, lambda {
    select("#{table_name}.*")
      .select(%(
      CASE
        WHEN aasm_state = 'convention_signed' THEN 0
        WHEN aasm_state = 'drafted' THEN 1
        WHEN aasm_state = 'approved' THEN 2
        WHEN aasm_state = 'submitted' THEN 3
        WHEN aasm_state = 'rejected' THEN 4
        ELSE 0
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

  #
  # Other stuffs
  #
  scope :default_order, ->{ order(updated_at: :desc) }
  scope :for_user, ->(user:) { where(user_id: user.id) }
  scope :not_by_id, ->(id:) { where.not(id: id) }

  scope :weekly_framed, -> { where(type: InternshipApplications::WeeklyFramed.name) }
  singleton_class.send(:alias_method, :troisieme_generale, :weekly_framed)

  scope :free_date, -> { where(type: InternshipApplications::FreeDate.name) }
  singleton_class.send(:alias_method, :voie_pro, :free_date)

  # add an additional delay when sending email using richtext
  # sometimes email was sent before action_texts_rich_text was persisted
  def deliver_later_with_additional_delay
    yield.deliver_later(wait: 1.second)
  end

  def weekly_offer?
    internship_offer.weekly?
  end

  aasm do
    state :drafted, initial: true
    state :submitted,
          :approved,
          :rejected,
          :expired,
          :canceled_by_employer,
          :canceled_by_student,
          :convention_signed

    event :submit do
      transitions from: :drafted, to: :submitted, after: proc { |*_args|
        update!("submitted_at": Time.now.utc)
        EmployerMailer.internship_application_submitted_email(internship_application: self)
                      .deliver_later
      }
    end

    event :expire do
      transitions from: %i[approved submitted drafted], to: :expired, after: proc { |*_args|
        update!(expired_at: Time.now.utc)
      }
    end

    event :approve do
      transitions from: %i[submitted cancel_by_employer rejected],
                  to: :approved,
                  after: proc { |*_args|
                          update!("approved_at": Time.now.utc)
                          if student.email.present?
                            deliver_later_with_additional_delay do
                              StudentMailer.internship_application_approved_email(internship_application: self)
                            end
                          elsif student.phone.present?
                            sms_message = "Monstagedetroisieme.fr : Votre candidature a " \
                                          "été acceptée ! Consultez-la ici : #{short_target_url(self)}"
                            SendSmsJob.perform_later(
                              user: student,
                              message: sms_message
                            ) unless Rails.env.development?
                          else
                            mesg = "while internship ##{id} has been accepted," \
                                   " no message has been sent to the " \
                                   "student ##{student.id}"
                            Rails.logger.error(mesg)
                          end

                          student.school.main_teachers.map do |main_teacher|
                            MainTeacherMailer.internship_application_approved_email(internship_application: self,
                                                                                    main_teacher: main_teacher)
                                             .deliver_later
                          end
                        }
    end

    event :reject do
      transitions from: :submitted,
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
      transitions from: %i[drafted submitted approved],
                  to: :canceled_by_employer,
                  after: proc { |*_args|
                           update!("canceled_at": Time.now.utc)
                           if student.email.present?
                              deliver_later_with_additional_delay do
                                StudentMailer.internship_application_canceled_by_employer_email(internship_application: self)
                              end
                           end
                         }
    end

    event :cancel_by_student do
      transitions from: %i[submitted approved],
                  to: :canceled_by_student,
                  after: proc { |*_args|
                           update!("canceled_at": Time.now.utc)
                           deliver_later_with_additional_delay do
                             EmployerMailer.internship_application_canceled_by_student_email(
                               internship_application: self
                             )
                           end
                         }
    end

    event :signed do
      transitions from: :approved, to: :convention_signed, after: proc { |*_args|
        update!(convention_signed_at: Time.now.utc)
        if respond_to?(:internship_offer_week)
          student.expire_application_on_week(week: internship_offer_week.week,
                                             keep_internship_application_id: id)
        end
      }
    end
  end

  scope :approved_or_signed, lambda {
    applications = InternshipApplication.arel_table
    where(applications[:aasm_state].in(['approved', 'signed']))
  }

  def internship_application_counter_hook
    case self
    when InternshipApplications::WeeklyFramed
      InternshipApplicationCountersHooks::WeeklyFramed.new(internship_application: self)
    when InternshipApplications::FreeDate
      InternshipApplicationCountersHooks::FreeDate.new(internship_application: self)
    else
      raise 'can not process stats for this kind of internship_application'
    end
  end

  def internship_application_aasm_message_builder(aasm_target:)
    case self
    when InternshipApplications::WeeklyFramed
      InternshipApplicationAasmMessageBuilders::WeeklyFramed.new(internship_application: self, aasm_target: aasm_target)
    when InternshipApplications::FreeDate
      InternshipApplicationAasmMessageBuilders::FreeDate.new(internship_application: self, aasm_target: aasm_target)
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

  def student_is_custom_track?
    student.custom_track?
  end

  def application_via_school_manager?
    internship_offer&.school
  end

  def anonymize
    motivation.try(:delete)
  end

  def new_format?
    return true if new_record?
    return false if created_at < Date.parse('01/09/2020')

    true
  end

  def short_target_url(application)
    target = Rails.application
                  .routes
                  .url_helpers
                  .dashboard_students_internship_application_url(
                    application.student.id,
                    application.id,
                    Rails.configuration.action_mailer.default_url_options
                  )
    UrlShortener.short_url(target)
  end
end
