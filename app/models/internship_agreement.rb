# Agreements can be created/modified by two kind of user
# - employer, allowed to manage following fields: TODO
# - school_manager, allowed to manage following fields: TODO
# - main_teacher, allowed to manage following fields: TODO
#
# to switch/branch validation, we use an home made mechanism
# which requires either one of those fields:
# - enforce_employer_validation : forcing employer validations
# - enforce_school_manager_validations : forcing school_manager validations
# - enforce_main_teacher_validations : forcing main_teacher validations
#
# only use dedicated builder to CRUD those objects
class InternshipAgreement < ApplicationRecord
  include AASM
  include Discard::Model

  belongs_to :internship_application
  has_many :signatures, dependent: :destroy

  has_rich_text :activity_scope_rich_text
  has_rich_text :activity_preparation_rich_text
  has_rich_text :activity_learnings_rich_text
  has_rich_text :activity_rating_rich_text

  # beware, complementary_terms_rich_text/lega_terms_rich_text are recopy from school.internship_agreement_presets.*
  #         it must stay a recopy and not a direct link (must live separatery)
  has_rich_text :complementary_terms_rich_text
  has_rich_text :legal_terms_rich_text

  attr_accessor :enforce_school_manager_validations,
                :enforce_employer_validations,
                :enforce_main_teacher_validations,
                :skip_validations_for_system

  with_options if: :enforce_main_teacher_validations? do
    validates :student_class_room, presence: true
    validates :main_teacher_full_name, presence: true
  end

  with_options if: :enforce_school_manager_validations? do
    validates :school_representative_full_name,
              :school_representative_phone,
              :school_representative_role,
              :school_representative_email,
              :student_full_name,
              :student_school,
              :student_refering_teacher_full_name,
              :student_refering_teacher_email,
              :student_refering_teacher_phone,
              :student_address,
              :student_phone,
              :student_legal_representative_full_name,
              :student_legal_representative_email,
              :student_legal_representative_phone,
              presence: true
    validate :valid_trix_school_manager_fields
  end

  with_options if: :enforce_employer_validations? do
    validates :organisation_representative_full_name,
              :organisation_representative_role,
              :date_range,
              :siret,
              :tutor_full_name,
              :tutor_role,
              :tutor_email,
              presence: true
    validate :valid_trix_employer_fields
    validate :valid_working_hours_fields
  end

  # validate :at_least_one_validated_terms

  aasm do
    state :draft, initial: true
    state :started_by_employer,
          :completed_by_employer,
          :started_by_school_manager,
          :validated,
          :signatures_started,
          :signed_by_all

    event :start_by_employer do
      transitions from: :draft,
                  to: :started_by_employer
    end

    event :complete do
      transitions from: %i[draft started_by_employer],
                  to: :completed_by_employer,
                  after: proc { |*_args|
        notify_school_manager_of_employer_completion(self)
      }
    end

    event :start_by_school_manager do
      transitions from: :completed_by_employer,
                  to: :started_by_school_manager
    end

    # validate is a reserved keyword and finalize is used instead
    event :finalize do
      transitions from: %i[completed_by_employer started_by_school_manager],
                  to: :validated,
                  after: proc { |*_args|
        notify_employer_school_manager_completed(self)
      }
    end

    event :sign do
      transitions from: %i[validated signatures_started],
                  to: :signatures_started,
                  after: proc { |*_args|
        notify_others_signatures_started(self)
      }
    end

    event :signatures_finalize do
      transitions from: [:signatures_started],
                  to: :signed_by_all,
                  after: proc { |*_args|
        notify_others_signatures_finished(self)
      }
    end
  end

  delegate :student,               to: :internship_application
  delegate :internship_offer,      to: :internship_application
  delegate :employer,              to: :internship_offer
  delegate :school,                to: :student
  delegate :school_manager,        to: :school
  delegate :internship_offer_area, to: :internship_offer

  scope :having_school_manager, ->{
    kept.joins(internship_application: {student: :school})
        .merge(School.with_school_manager)
  }

  scope :filtering_discarded_students, ->{
    joins(internship_application: :student)
      .where(internship_application: {users: {discarded_at: nil}})
  }

  def at_least_one_validated_terms
    return true if skip_validations_for_system
    return true if [school_manager_accept_terms, employer_accept_terms, main_teacher_accept_terms].any?

    if [enforce_employer_validations?,
        enforce_main_teacher_validations?,
        enforce_school_manager_validations?].none?
      %i[
        main_teacher_accept_terms
        school_manager_accept_terms
        employer_accept_terms
      ].each do |term|
        errors.add(term, term)
      end
    end
  end

  def enforce_main_teacher_validations?
    enforce_main_teacher_validations == true
  end

  def enforce_school_manager_validations?
    enforce_school_manager_validations == true
  end

  def enforce_employer_validations?
    enforce_employer_validations == true
  end

  def confirmed_by?(user:)
    return school_manager_accept_terms? if user.school_manager?
    return main_teacher_accept_terms? if user.main_teacher?
    return employer_accept_terms? if user.employer?

    raise ArgumentError, "#{user.type} does not support accept terms yet "
  end

  def valid_trix_employer_fields
    if activity_scope_rich_text.blank?
      errors.add(:activity_scope_rich_text,
                 'Veuillez compléter les objectifs du stage')
    end
    if complementary_terms_rich_text.blank?
      errors.add(:complementary_terms_rich_text,
                 'Veuillez compléter les conditions complémentaires du stage (hebergement, transport, securité)...')
    end
  end

  def valid_trix_school_manager_fields
    if complementary_terms_rich_text.blank?
      errors.add(:complementary_terms_rich_text,
                 'Veuillez compléter les conditions complémentaires du stage (hebergement, transport, securité)...')
    end
  end

  def valid_working_hours_fields
    if weekly_planning?
      unless valid_weekly_planning?
        errors.add(:same_daily_planning,
                   'Veuillez compléter les horaires et repas de la journée de stage')
      end
    elsif daily_planning?
      unless valid_daily_planning?
        errors.add(:weekly_planning,
                   'Veuillez compléter les horaires et repas de la semaine de stage')
      end
    else
      errors.add(:weekly_planning, 'Veuillez compléter les horaires du stage')
    end
  end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end

  def valid_weekly_planning?
    weekly_hours.any?(&:present?)
  end

  def daily_planning?
    return false if daily_hours.blank?

    daily_hours.except('samedi').values.flatten.any? { |v| v.present? }
  end

  def valid_daily_planning?
    # daily_hours sample data :
    # {"jeudi"=>["11:45", "16:00"], "lundi"=>["11:45", "15:45"], "mardi"=>["12:00", "16:00"], "samedi"=>["", ""], "mercredi"=>["12:00", "16:00"], "vendredi"=>["", ""]}
    # {"jeudi"=>"a good meal", "lundi"=>"a good meal", "mardi"=>"a good meal", "samedi"=>"a good meal "mercredi"=>"a good meal", "vendredi"=>"a good meal"}
    daily_hours_ok = daily_hours.except('samedi').values.all? do |v|
      v.first.present? && v.second.present?
    end
    
    daily_hours_ok && (weekly_lunch_break.present? || lunch_break.present?)
  end

  def roles_not_signed_yet
    Signature.signatory_roles.keys - roles_already_signed
  end

  def signature_by_role(signatory_role:)
    return nil if signatures.blank?

    signatures.find_by(signatory_role: signatory_role)
  end

  def signature_image_attached?(signatory_role:)
    signature = signature_by_role(signatory_role: signatory_role)
    return signature.signature_image.attached? if signature && signature.signature_image

    false
  end

  def ready_to_sign?(user:)
    aasm_state.to_s.in?(%w[validated signatures_started]) && \
      !signed_by?(user: user) && \
      user.can_sign?(self)
  end

  def signed_by?(user:)
    signatures.pluck(:user_id).include?(user.id)
  end

  def signed_by_school?
    signatures.pluck(:signatory_role).include?('school_manager')
  end

  def presenter(user:)
    Presenters::InternshipAgreement.new(self, user)
  end

  def roles_not_signed_yet
    Signature.signatory_roles.keys - roles_already_signed
  end

  def signature_by_role(signatory_role:)
    return nil if signatures.blank?

    signatures.find_by(signatory_role: signatory_role)
  end

  def signature_image_attached?(signatory_role:)
    signature = signature_by_role(signatory_role:signatory_role)
    return signature.signature_image.attached? if signature && signature.signature_image

    false
  end

  def signed_by?(user:)
    return false if user.nil?

    signatures.pluck(:user_id).include?(user.id)
  end

  def archive
    fields_to_reset = {
      organisation_representative_full_name: 'NA',
      school_representative_full_name: 'NA',
      student_full_name: 'NA',
      student_class_room: 'NA',
      student_school: 'NA',
      tutor_full_name: 'NA',
      main_teacher_full_name: 'NA',
      siret: 'NA',
      tutor_role: 'NA',
      tutor_email: 'NA',
      organisation_representative_role: 'NA',
      student_address: 'NA',
      student_phone: 'NA',
      school_representative_phone: 'NA',
      student_refering_teacher_phone: 'NA',
      student_legal_representative_email: 'NA',
      student_refering_teacher_email: 'NA',
      student_legal_representative_full_name: 'NA',
      student_refering_teacher_full_name: 'NA',
      student_legal_representative_2_full_name: 'NA',
      student_legal_representative_2_email: 'NA',
      student_legal_representative_2_phone: 'NA',
      school_representative_role: 'NA',
      school_representative_email: 'NA',
      student_legal_representative_phone: 'NA'
    }
    update_columns(fields_to_reset)
    discard! unless discarded?
  end


  private

  def notify_employer_school_manager_completed(agreement)
    EmployerMailer.school_manager_finished_notice_email(
      internship_agreement: agreement
    ).deliver_later
  end

  def notify_others_signatures_started(agreement)
    roles_not_signed_yet.each do |role|
      mailer_map[role.to_sym].notify_others_signatures_started_email(
        internship_agreement: agreement
      ).deliver_later
    end
  end

  def notify_others_signatures_finished(agreement)
    every_signature_but_mine.each do |signature|
      role = signature.signatory_role.to_sym
      mailer_map[role].notify_others_signatures_finished_email(
        internship_agreement: agreement
      ).deliver_later
    end
  end

  def notify_school_manager_of_employer_completion(agreement)
    SchoolManagerMailer.internship_agreement_completed_by_employer_email(
      internship_agreement: agreement
    ).deliver_later
  end

  def every_signature_but_mine
    # every signature role but mine (and I'm the last one to have signed)
    signatures.order(created_at: :asc).to_a[0..-2]
  end

  def roles_already_signed
    Signature.where(internship_agreement_id: id)
             .pluck(:signatory_role)
  end

  def mailer_map
    {
      school_manager: SchoolManagerMailer,
      employer: EmployerMailer
    }
  end

  rails_admin do
    weight 14
    navigation_label 'Offres'

    list do
      field :id
      field :internship_application
      field :aasm_state
      field :school_manager_accept_terms
      field :employer_accept_terms
    end
  end
end
