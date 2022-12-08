# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipAgreementBuilder < BuilderBase

    def new_from_application(internship_application)
      authorize :new, InternshipAgreement
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_student_to_params(internship_application.student))
          .merge(preprocess_internship_offer_params(internship_application.internship_offer))
          .merge(preprocess_internship_application_params(internship_application))
          .merge(preprocess_internship_agreement_preset(internship_application))
      )
      internship_agreement.internship_application = internship_application
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
      return { enforce_employer_validations: true } if user.employer_like?
      return { skip_validations_for_system: true } if user.is_a?(Users::God)
      raise ArgumentError, "#{user.type} can not create agreement yet"
    end

    def preprocess_internship_application_params(internship_application)
      {
        date_range: internship_application.week.short_select_text_method
      }
    end

    def preprocess_internship_agreement_preset(internship_application)
      internship_agreement_preset = internship_application.student.school.internship_agreement_preset

      params = {
        school_delegation_to_sign_delivered_at: internship_agreement_preset.school_delegation_to_sign_delivered_at,
        legal_terms_rich_text: internship_agreement_preset.legal_terms_rich_text.body,
        complementary_terms_rich_text: internship_agreement_preset.complementary_terms_rich_text.body
      }
      params[:activity_rating_rich_text] = internship_agreement_preset.troisieme_generale_activity_rating_rich_text if internship_application.student.class_room.try(:troisieme_generale?)
      params
    end

    def preprocess_internship_offer_params(internship_offer)
      {
        organisation_representative_full_name: internship_offer.employer.presenter.full_name,
        organisation_representative_role: internship_offer.employer.employer_role,
        siret: internship_offer.try(:siret),
        tutor_full_name: internship_offer.tutor_name,
        tutor_role: internship_offer.try(:tutor_role),
        tutor_email: internship_offer.try(:tutor_email),
        activity_preparation_rich_text: internship_offer.description_rich_text.body,
        new_daily_hours: internship_offer.new_daily_hours,
        weekly_hours: internship_offer.weekly_hours,
        daily_lunch_break: internship_offer.daily_lunch_break,
        weekly_lunch_break: internship_offer.weekly_lunch_break,
      }
    end

    def preprocess_student_to_params(student)
      main_teacher = student&.class_room&.main_teacher
      school_manager = student.school_manager
      if student.class_room
        main_teacher_full_name = main_teacher&.name
        student_class_room = student&.class_room&.name
      else
        main_teacher_full_name = 'N/A'
        student_class_room = ""
      end
      {
        student_school: student.presenter.formal_school_name,
        school_representative_full_name: school_manager&.presenter&.full_name,
        school_representative_phone: school_manager.try(:phone),
        school_representative_role: "Chef d'établissement",
        school_representative_email: school_manager&.email,
        student_refering_teacher_full_name: main_teacher&.presenter&.full_name,
        student_refering_teacher_email: main_teacher&.email,
        student_refering_teacher_phone: main_teacher&.phone,
        student_phone: student.phone,
        school_track: student.school_track || 'troisieme_generale',
        student_full_name: student.name,
        student_class_room: student_class_room,
        main_teacher_full_name: main_teacher_full_name
      }
      # student_class_room is not used ...
    end

  end
end
