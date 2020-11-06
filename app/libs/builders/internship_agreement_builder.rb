# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipAgreementBuilder < BuilderBase

    def new_from_application(internship_application)
      authorize :new, InternshipAgreement
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_student_to_params(internship_application.student))
          .merge(preprocess_internship_offer_params(internship_application.internship_offer))
      )
      internship_agreement.internship_application = internship_application
      internship_agreement.terms_rich_text.body = "<div>#{InternshipAgreement::TERMS}</div>"
      internship_agreement
    end

    def create(params:)
      yield callback if block_given?
      internship_agreement = InternshipAgreement.new(params)
      authorize :create, internship_agreement
      internship_agreement.save!
      callback.on_success.try(:call, internship_agreement)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.attributes = params
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
        student_school: student.school,
        school_representative_full_name: student.school.school_manager.name,
        student_full_name: student.name,
        student_class_room: student.class_room.try(:name),
        main_teacher_full_name: student.class_room.school_managements.main_teachers.first.try(:name)
      }
    end

  end
end
