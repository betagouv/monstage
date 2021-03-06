# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipAgreementBuilder < BuilderBase

    def new_from_application(internship_application)
      authorize :new, InternshipAgreement
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_student_to_params(internship_application.student))
          .merge(preprocess_internship_offer_params(internship_application.internship_offer))
          .merge(preprocess_internship_application_paramns(internship_application))
      )
      internship_agreement.internship_application = internship_application
      internship_agreement.terms_rich_text.body = "<div>#{InternshipAgreement::CONVENTION_LEGAL_TERMS}</div>"
      internship_agreement.financial_conditions_rich_text.body = internship_application.student.school.agreement_conditions_rich_text.body || "<div>#{InternshipAgreement::CONVENTION_FINANCIAL_TERMS}</div>"
      internship_agreement
    end

    def create(params:)
      yield callback if block_given?
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_terms)
          .merge(params)
      )
      authorize :create, internship_agreement
      internship_agreement.save!
      callback.on_success.try(:call, internship_agreement)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.attributes = {}.merge(preprocess_terms)
                              .merge(params)
      instance.save!
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    private

    attr_reader :user, :ability, :callback

    def initialize(user:)
      @user = user
      @ability = Ability.new(user)
      @callback = Callback.new
    end

    def preprocess_terms
      return { enforce_school_manager_validations: true } if user.school_manager?
      return { enforce_main_teacher_validations: true } if user.main_teacher?
      return { enforce_employer_validations: true } if user.is_a?(Users::Employer)
      raise ArgumentError, "#{user.type} can not create agreement yet"
    end

    def preprocess_internship_application_paramns(internship_application)
      {
        date_range: internship_application.week.short_select_text_method
      }
    end

    def preprocess_internship_offer_params(internship_offer)
      {
        organisation_representative_full_name: internship_offer.employer_name,
        tutor_full_name: internship_offer.tutor_name,
        activity_scope_rich_text: internship_offer.title,
        activity_preparation_rich_text: internship_offer.description_rich_text.body,
        new_daily_hours: internship_offer.new_daily_hours,
        weekly_hours: internship_offer.weekly_hours,
      }
    end

    def preprocess_student_to_params(student)
      {
        student_school: "#{student.school} à #{student.school.city} (Code UAI: #{student.school.code_uai})",
        school_representative_full_name: student.school.school_manager.name,
        student_full_name: student.name,
        student_class_room: student.class_room.try(:name),
        main_teacher_full_name: student.class_room.school_managements.main_teachers.first.try(:name)
      }
    end

  end
end
