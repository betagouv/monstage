# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipAgreements
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def make_internship_agreement_params(internship_application)
      internship_agreement = build(:internship_agreement, internship_application: internship_application)

      {
        'internship_application_id'             => internship_application.id,
        'student_school'                        => internship_agreement.student_school,
        'school_representative_full_name'       => internship_agreement.school_representative_full_name,
        'student_full_name'                     => internship_agreement.student_full_name,
        'student_class_room'                    => internship_agreement.student_class_room,
        'main_teacher_full_name'                => internship_agreement.main_teacher_full_name,
        'organisation_representative_full_name' => internship_agreement.organisation_representative_full_name,
        'tutor_full_name'                       => internship_agreement.tutor_full_name,
        'start_date'                            => internship_agreement.start_date,
        'end_date'                              => internship_agreement.end_date,
        'activity_scope_rich_text'              => '<div>Activité Scope</div>',
        'activity_preparation_rich_text'        => '<div>Activité Préparation</div>',
        'weekly_hours' => ['9h', '12h'],
        'activity_learnings_rich_text'          => '<div>Apprentissages</div>',
        'activity_rating_rich_text'             => '<div>Notations</div>',
        'housing_rich_text'                     => '<div>Hébergement</div>',
        'insurance_rich_text'                   => '<div>Assurance</div>',
        'transportation_rich_text'              => '<div>Transport</div>',
        'food_rich_text'                        => '<div>Restauration</div>',
        'terms_rich_text'                       => '<div>Article 1</div>'
      }

    end

    #
    # as School Manager
    #
    test 'POST #create as School Manager' do
      school = create(:school, :with_school_manager)
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      class_room = create(:class_room, school: school)
      internship_application.student.update(class_room_id: class_room.id, school_id: school.id)
      sign_in(school.school_manager)

      params = make_internship_agreement_params(internship_application).merge(
        'school_manager_accept_terms'           => true
      )
      assert_difference('InternshipAgreement.count', 1) do
        post(dashboard_internship_agreements_path, params: { internship_agreement: params })
      end
    end

    test 'POST #create as School Manager fail when school_manager_accept_terms missing' do
      school = create(:school, :with_school_manager)
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      class_room = create(:class_room, school: school)
      internship_application.student.update(class_room_id: class_room.id, school_id: school.id)
      sign_in(school.school_manager)

      params = make_internship_agreement_params(internship_application).except('school_manager_accept_terms')
      assert_no_difference('InternshipAgreement.count') do
        post(dashboard_internship_agreements_path, params: { internship_agreement: params })
      end
    end

    test 'POST #create as School Manager when student is from anonther school' do
      operator = create(:user_operator)
      school = create(:school, :with_school_manager)
      another_school = create(:school, :with_school_manager)
      internship_offer = create(:weekly_internship_offer, employer: operator,
        is_public: true,
        max_candidates: 2)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      class_room = create(:class_room, school: another_school)
      internship_application.student.update(class_room_id: class_room.id, school_id: another_school.id)
      internship_agreement = build(:internship_agreement, internship_application: internship_application)
      sign_in(school.school_manager)

      params = make_internship_agreement_params(internship_application)

      assert_difference('InternshipAgreement.count', 0) do
        post(dashboard_internship_agreements_path, params: { internship_agreement: params })
      end
    end

    #
    # as Employer
    #
    test 'POST #create as Employer' do
      internship_application = create(:weekly_internship_application, :approved)
      sign_in(internship_application.internship_offer.employer)

      params = make_internship_agreement_params(internship_application).merge(
        'employer_accept_terms'           => true
      )
      assert_difference('InternshipAgreement.count', 1) do
        post(dashboard_internship_agreements_path, params: { internship_agreement: params })
      end
    end

    test 'POST #create as Employer fail when employer_accept_terms missing' do
      internship_application = create(:weekly_internship_application, :approved)
      sign_in(internship_application.internship_offer.employer)

      params = make_internship_agreement_params(internship_application).except('employer_accept_terms')
      assert_no_difference('InternshipAgreement.count') do
        post(dashboard_internship_agreements_path, params: { internship_agreement: params })
      end
    end
  end
end
