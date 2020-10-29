# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipAgreementBuilder

    def new_from_application(internship_application)
      internship_agreement = InternshipAgreement.new(
        {}.merge(preprocess_student_to_params(internship_application.student))
          .merge(preprocess_internship_offer_params(internship_application.internship_offer))
      )
      internship_agreement.terms_rich_text.body = "<div>#{InternshipAgreement::TERMS}</div>"
      internship_agreement
    end
   
    private

    attr_reader :user, :ability

    def initialize(user:)
      @user = user
      @ability = Ability.new(user)
    end

    def preprocess_internship_offer_params(internship_offer)
      {
        organisation_representative_full_name: internship_offer.employer_name,
        tutor_full_name: internship_offer.tutor_name,
        activity_scope_rich_text: internship_offer.title,
        activity_preparation_rich_text: internship_offer.description_rich_text.body,
        activity_schedule_rich_text: preprocess_schedule(internship_offer),
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

    def authorize(*vargs)
      return nil if ability.can?(*vargs)

      raise CanCan::AccessDenied
    end

    def preprocess_schedule(internship_offer)
      if internship_offer.daily_hours.present?
        internship_offer.daily_hours.map.with_index { |day, i| "<div>#{I18n.t('date.day_names')[i+1].capitalize} : #{day[0]} - #{day[1]}</div>" }.join("</br>")
      end
      if internship_offer.weekly_hours.present?
        "<div>Du lundi au vendredi : #{internship_offer.weekly_hours[0]} - #{internship_offer.weekly_hours[1]}</div>"
      end
    end
  end
end
