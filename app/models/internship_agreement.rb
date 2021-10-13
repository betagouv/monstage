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
  include SchoolTrackable
  include AASM

  belongs_to :internship_application

  has_rich_text :activity_scope_rich_text
  has_rich_text :activity_preparation_rich_text
  has_rich_text :activity_learnings_rich_text
  has_rich_text :activity_rating_rich_text

  # beware, complementary_terms_rich_text/lega_terms_rich_text are recopy from school.internship_agreement_presets.*
  #         it must stay a recopy and not a direct link (must live separatery)
  has_rich_text :complementary_terms_rich_text
  has_rich_text :legal_terms_rich_text

  attr_accessor :enforce_school_manager_validations
  attr_accessor :enforce_employer_validations
  attr_accessor :enforce_tutor_validations
  attr_accessor :enforce_main_teacher_validations
  attr_accessor :skip_validations_for_system

  # todo flip based on current switch/branch
  # with_options if: :enforce_main_teacher_validations? do
  #   validates :student_class_room, presence: true
  #   validates :main_teacher_full_name, presence: true
  #   validate :valid_trix_main_teacher_fields
  # end

  # with_options if: :enforce_school_manager_validations? do
  #   validates :student_school, presence: true
  #   validates :school_representative_full_name, presence: true
  #   validates :student_full_name, presence: true
  #   validate :valid_trix_school_manager_fields
  # end

  # with_options if: :enforce_employer_validations? do
  #   validates :organisation_representative_full_name, presence: true
  #   validates :tutor_full_name, presence: true
  #   validates :date_range, presence: true
  #   validate :valid_trix_employer_fields
  # end

  # validate :at_least_one_validated_terms

  aasm do
    state :draft, initial: true
    state :started_by_employer,
          :completed_by_employer,
          :validated,
          :signed

    event :start_by_employer do
      transitions from: :draft, to: :started_by_employer
    end

    event :complete do
      transitions from: %i[draft started_by_employer], to: :completed_by_employer
    end

    event :validate do
      transitions from: :completed_by_employer, to: :validated
    end
  end

  with_options if: :enforce_tutor_validations? do
    validates :tutor_full_name, presence: true
    validates_inclusion_of :tutor_accept_terms,
                           in: ['1', true],
                           message: :missing
    validate :valid_trix_tutor_fields
  end

  validate :at_least_one_validated_terms


  def at_least_one_validated_terms
    return true if skip_validations_for_system
    return true if [school_manager_accept_terms, employer_accept_terms, main_teacher_accept_terms, tutor_accept_terms].any?

    if [enforce_employer_validations?,
        enforce_main_teacher_validations?,
        enforce_school_manager_validations?,
        enforce_tutor_validations?
       ].none?
      %i[
        main_teacher_accept_terms
        school_manager_accept_terms
        employer_accept_terms
        tutor_accept_terms
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

  def enforce_tutor_validations?
    enforce_tutor_validations == true
  end

  def confirmed_by?(user:)
    return school_manager_accept_terms? if user.school_manager?
    return main_teacher_accept_terms? if user.main_teacher?
    return tutor_accept_terms? if user.tutor?
    return employer_accept_terms? if user.employer?

    raise  ArgumentError, "#{user.type} does not support accept terms yet "
  end

  def valid_trix_employer_fields
    if activity_scope_rich_text.blank?
      errors.add(:activity_scope_rich_text,
                 "Veuillez compléter les objectifs du stage")
    end
    if complementary_terms_rich_text.blank?
      errors.add(:complementary_terms_rich_text,
                 "Veuillez compléter les conditions complémentaires du stage (hebergement, transport, securité)...")
    end
    if !troisieme_generale? && activity_learnings_rich_text.blank?
      errors.add(:activity_learnings_rich_text,
                 "Veuillez compléter les compétences visées")
    end
  end

  def valid_trix_tutor_fields
  end

  def valid_trix_school_manager_fields
    if complementary_terms_rich_text.blank?
      errors.add(:complementary_terms_rich_text,
                  "Veuillez compléter les conditions complémentaires du stage (hebergement, transport, securité)...")
    end
    if !troisieme_generale? && activity_rating_rich_text.blank?
      errors.add(:activity_rating_rich_text,
                  "Veuillez compléter les modalités d’évaluation du stage")
    end
  end

  def valid_trix_main_teacher_fields
    if !troisieme_generale? && activity_preparation_rich_text.blank?
      errors.add(:activity_preparation_rich_text, "Veuillez compléter les modalités de concertation")
    end
  end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end
end
