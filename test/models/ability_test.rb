# frozen_string_literal: true

require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test 'Visitor' do
    ability = Ability.new
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.can?(:apply, InternshipOffer.new),
           'visitors should be lured into thinking that they can apply directly')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test 'Student' do
    internship_offer = create(:weekly_internship_offer)
    school = create(:school, weeks: [internship_offer.weeks.first])
    student = create(:student, class_room: create(:class_room, :troisieme_generale, school: school))
    ability = Ability.new(student)
    internship_application = create(:weekly_internship_application,
                                    student: student,
                                    internship_offer: internship_offer,
                                    week: internship_offer.internship_offer_weeks.first.week)

    assert(ability.can?(:look_for_offers, student), 'students should be able to look for offers')
    assert(ability.can?(:read, InternshipOffer.new),
           'students should be able to consult internship offers')
    assert(ability.can?(:apply, internship_offer),
           'students should be able to apply for internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'students should not be able to con manage internships')
    assert(ability.can?(:show, :account),
           'students should be able to access their account')
    assert(ability.can?(:choose_school, student),
           'student should be able to choose_school')
    assert(ability.can?(:choose_class_room, student),
           'student should be able to choose_class_room')
    assert(ability.can?(:choose_gender_and_birthday, student),
           'student should be able to choose_gender_and_birthday')
    assert(ability.can?(:choose_handicap, student),
           'student should be able to choose handicap')
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))
    assert(ability.cannot?(:index, Acl::InternshipOfferDashboard.new(user: student)),
           'employers should be able to index InternshipOfferDashboard')

    student_2 = create(:student) # with no class_room
    ability = Ability.new(student_2)
    assert(ability.can?(:apply, internship_offer),
           'students should be able to apply for internship offers')
    
  end

  test 'Employer' do

    employer = create(:employer)
    another_employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    alt_internship_offer = create(:weekly_internship_offer, employer: another_employer)
    internship_offer_api = create(:api_internship_offer, employer: employer)
    free_date_internship_offer = create(:free_date_internship_offer, employer: employer)
    free_date_internship_offer.update_columns(first_date: Date.new(2020, 9 ,1), last_date: Date.new(2020, 9,2))
    alt_free_date_internship_offer = create(:free_date_internship_offer, employer: another_employer)
    alt_free_date_internship_offer.update_columns(first_date: Date.new(2020, 9 ,1), last_date: Date.new(2020, 9,2))
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    internship_agreement   = create(:troisieme_generale_internship_agreement, :created_by_system,
                                    internship_application: internship_application)
    ability = Ability.new(employer)

    assert(ability.can?(:choose_function, User.new),
          'employers can declare their role in their organisation')
    assert(ability.can?(:subscribe_to_webinar, User.new),
          'employers can subscribe to webinars')
    assert(ability.can?(:supply_offers, employer), 'employers are to be able to supply offers')
    assert(ability.can?(:create, InternshipOffer.new),
           'employers should be able to create internships')
    assert(ability.cannot?(:update, InternshipOffer.new),
           'employers should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffer.new(employer: employer)),
          'employers should be able to update internships offer that belongs to him')

    #renewing
    # -------------------
    assert(ability.cannot?(:renew, InternshipOffer.new),
          'employers should not be able to renew internship that are not persisted')
    travel_to(internship_offer.internship_offer_weeks.last.week.week_date.to_date + 1.year) do
       assert(ability.can?(:renew, internship_offer),
           'employers should be able to renew internships offer that belongs to him')
       assert(ability.can?(:renew, internship_offer_api), 'api internship_offers can be renewed')
    end
    travel_to(Date.new(Date.today.year - 1 ,9,1)) do
       assert(ability.cannot?(:renew, internship_offer),
           'employers should be able to renew offer on 1st sept. date comparission less or equal')
    end

    assert(ability.can?(:renew, free_date_internship_offer),
           'employers should be able to renew offer that is a FreeDate one')
    assert(ability.cannot?(:renew, alt_free_date_internship_offer),
           'employers should not be able to renew offer that do not belong to him')
    travel_to(Date.new(2020, 9, 1)) do
          assert(ability.cannot?(:renew, free_date_internship_offer, user: employer),
           'employers should be able to renew free_date offer are not in the passed')
    end

    #duplicating
    # -------------------
    assert(ability.cannot?(:duplicate, InternshipOffers::FreeDate.new, user: employer),
           'employers should not be able to duplicate a not persisted offer')
    assert(ability.cannot?(:duplicate, alt_internship_offer),
           'employers should not be able to duplicate offers that do not belong to them')
    assert(ability.can?(:duplicate, internship_offer),
           'employers should be able to duplicate offers that do belong to them')
    travel_to(internship_offer.internship_offer_weeks.last.week.week_date.to_date + 1.year) do
      assert(ability.cannot?(:duplicate, internship_offer),
            'employers should not be able to duplicate offer of the passed')
    end
    travel_to(Date.new(2020,10, 1)) do
      assert(ability.can?(:duplicate, free_date_internship_offer),
            'employers should be able to duplicate offer that is a FreeDate one')
    end
    travel_to(Date.new(2021,8, 1)) do
      assert(ability.cannot?(:duplicate, free_date_internship_offer),
            'employers should be able to duplicate offer that is a FreeDate one')
    end
    # -------------------

    assert(ability.cannot?(:discard, InternshipOffer.new),
           'employers should be able to discard internships offer not belonging to him')
    assert(ability.can?(:discard, InternshipOffer.new(employer: employer)),
           'employers should be able to discard internships offer that belongs to him')
    assert(ability.can?(:index, Acl::InternshipOfferDashboard.new(user: employer)),
           'employers should be able to index InternshipOfferDashboard')
    assert(ability.can?(:create_remote_internship_request, SupportTicket),
           'employers should be able to ask how ask for remote internships support')
    %i[
    create
      edit
      edit_organisation_representative_role
      edit_tutor_email
      edit_tutor_role
      edit_activity_scope_rich_text
      edit_activity_preparation_rich_text
      edit_activity_learnings_rich_text
      edit_complementary_terms_rich_text
      edit_date_range
      edit_organisation_representative_full_name
      edit_siret
      edit_tutor_full_name
      edit_weekly_hours
      update
    ].each do |meth|
      assert(ability.can?(meth, internship_agreement), "Employer fail: #{meth}")
    end
    internship_agreement.update_columns(aasm_state: :started_to_sign)
    assert(ability.can?(:sign_with_sms, User))
    assert(ability.can?(:sign_internship_agreements, internship_agreement.reload), "Signature fails")
  end

  test 'God' do
    god = build(:god)
    ability = Ability.new(god)
    assert(ability.can?(:show, :account),
           'god should be able to see his account')
    assert(ability.can?(:update, School),
           'god should be able to manage school')
    assert(ability.can?(:edit, User),
           'god should be able to edit user')
    assert(ability.can?(:see_tutor, InternshipOffer),
           'god should be able see_tutor')
    assert ability.can?(:read, User)
    assert ability.can?(:destroy, User)
    assert ability.can?(:manage, Group)
    assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
    assert ability.can?(:index, Acl::Reporting.new(user: god, params: {}))
    refute ability.can?(:apply, create(:weekly_internship_offer))
    refute ability.can?(:apply, create(:free_date_internship_offer))
    refute ability.can?(:apply, create(:api_internship_offer))
    assert ability.can?(:new, InternshipAgreement)
    assert ability.can?(:see_reporting_dashboard, User)
    assert ability.can?(:see_reporting_internship_offers, User)
    assert ability.can?(:see_reporting_schools, User)
    assert ability.can?(:see_reporting_associations, User)
    assert ability.can?(:see_reporting_enterprises, User)
  end

  test 'Statistician' do
    statistician = create(:statistician)
    ability = Ability.new(statistician)

    assert(ability.can?(:supply_offers, statistician), 'statistician are to be able to supply offers')
    assert(ability.can?(:view, :department),
           'statistician should be able to view his own department')
    assert(ability.can?(:read, InternshipOffer))
    assert(ability.cannot?(:renew, InternshipOffer.new),
           'employers should not be able to renew internship offer not belonging to him')
    refute(ability.can?(:show, :account),
           'statistician should be able to see his account')
    refute(ability.can?(:update, School),
           'statistician should be able to manage school')
    refute(ability.can?(:edit, User),
           'statistician should be able to edit user')
    refute(ability.can?(:check_his_statistics, User),
           'statistician should be able to check his statistics')
    assert(ability.can?(:create, Tutor),
           'statistician should be able to create tutors')
    refute ability.can?(:read, User)
    refute ability.can?(:destroy, User)
    assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
    refute ability.can?(:index, Acl::Reporting.new(user: statistician, params: {}))
    assert(ability.can?(:index, Acl::Reporting, &:allowed?))

    refute ability.can?(:apply, create(:weekly_internship_offer))
    refute ability.can?(:apply, create(:free_date_internship_offer))
    refute ability.can?(:apply, create(:api_internship_offer))

    assert ability.can?(:see_reporting_dashboard, User)
    refute ability.can?(:see_dashboard_enterprises_summary, User)
    refute ability.can?(:see_reporting_schools, User)
    refute ability.can?(:see_reporting_associations, User)
    refute ability.can?(:see_reporting_enterprises, User)
  end

  test 'Education Statistician' do
    statistician = create(:education_statistician)
    ability = Ability.new(statistician)

    assert(ability.can?(:supply_offers, statistician), 'statistician are to be able to supply offers')
    assert(ability.can?(:view, :department),
           'statistician should be able to view his own department')
    assert(ability.can?(:read, InternshipOffer))
    assert(ability.cannot?(:renew, InternshipOffer.new),
           'employers should not be able to renew internship offer not belonging to him')
    refute(ability.can?(:show, :account),
           'statistician should be able to see his account')
    refute(ability.can?(:update, School),
           'statistician should be able to manage school')
    refute(ability.can?(:edit, User),
           'statistician should be able to edit user')
    assert(ability.can?(:subscribe_to_webinar, User.new),
          'statisticians can subscribe to webinars')
    assert(ability.can?(:choose_to_sign_agreements, User.new),
          'statisticians can decide to sign all agreements')
    assert(ability.can?(:create, Tutor),
           'statistician should be able to create tutors')
    refute ability.can?(:read, User)
    refute ability.can?(:destroy, User)
    assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
    refute ability.can?(:index, Acl::Reporting.new(user: statistician, params: {}))
    assert(ability.can?(:index, Acl::Reporting, &:allowed?))

    refute ability.can?(:apply, create(:weekly_internship_offer))
    refute ability.can?(:apply, create(:free_date_internship_offer))
    refute ability.can?(:apply, create(:api_internship_offer))

    assert ability.can?(:see_reporting_dashboard, User)
    refute ability.can?(:see_dashboard_enterprises_summary, User)
    refute ability.can?(:see_reporting_schools, User)
    refute ability.can?(:see_reporting_associations, User)
    refute ability.can?(:see_reporting_enterprises, User)
  end

  test 'MinistryStatistician' do
    ministry_statistician = create(:ministry_statistician)
    ministry = ministry_statistician.ministries.first
    ability = Ability.new(ministry_statistician)

    assert(ability.can?(:supply_offers, ministry_statistician), 'statistician are to be able to supply offers')
    assert(ability.can?(:index, Acl::Reporting, &:allowed?))
    assert(ability.can?(:read, Group),
           'ministry statistician should be able to view his own ministry')
    refute(ability.can?(:show, :account),
           'ministry_statistician should be able to see his account')
    refute(ability.can?(:update, School),
           'ministry_statistician should be able to manage school')
    refute(ability.can?(:edit, User),
           'ministry_statistician should be able to edit user')
    assert(ability.can?(:subscribe_to_webinar, ministry_statistician),
          'statisticians can subscribe to webinars')
    assert(ability.can?(:see_tutor, InternshipOffer),
           'ministry_statistician should be able see_tutor')
    refute ability.can?(:read, User)
    refute ability.can?(:destroy, User)
    assert ability.can?(:index_and_filter, Reporting::InternshipOffer)

    offer = create(:weekly_internship_offer,
       group_id: ministry.id,
       employer: ministry_statistician,
       is_public: true
    )

    refute ability.can?(:apply, create(:weekly_internship_offer))
    refute ability.can?(:apply, create(:free_date_internship_offer))
    refute ability.can?(:apply, create(:api_internship_offer))

    assert ability.can?(:see_reporting_dashboard, User)
    refute ability.can?(:see_reporting_internship_offers, User)
    refute ability.can?(:see_reporting_schools, User)
    refute ability.can?(:see_reporting_associations, User)
    refute ability.can?(:see_reporting_entreprises, User)
    assert ability.can?(:see_dashboard_enterprises_summary, User)
  end

  test 'SchoolManager' do
    student = create(:student)
    school = student.school
    another_school = create(:school)
    school_manager = create(:school_manager, school: school)
    internship_application = create(:weekly_internship_application, student: student)
    internship_agreement = create(:troisieme_generale_internship_agreement, :created_by_system,
                                  internship_application: internship_application)
    ability = Ability.new(school_manager)

    assert(ability.can?(:welcome_students, school_manager), 'school_manager are to be able to supply offers')
    assert(ability.can?(:choose_class_room, User))
    assert(ability.can?(:choose_role, User))
    assert(ability.can?(:choose_class_room, User))
    assert(ability.can?(:sign_with_sms, User))
    assert(ability.can?(:subscribe_to_webinar, school_manager))
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:delete, student))

    assert(ability.can?(:manage, ClassRoom))
    assert(ability.cannot?(:change, :class_room))

    assert(ability.can?(:destroy, internship_application))
    assert(ability.can?(:update, internship_application))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.can?(:submit_internship_application, internship_application))
    assert(ability.can?(:validate_convention, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))

    assert(ability.can?(:see_tutor, InternshipOffer))

    assert(ability.can?(:manage_school_users, school))
    assert(ability.can?(:manage_school_students, school))
    assert(ability.can?(:manage_school_internship_agreements, school))
    assert(ability.can?(:create_remote_internship_request, SupportTicket))

    assert(ability.cannot?(%i[show edit update], School),
           'school_manager should be able manage school')
    assert(ability.cannot?(:manage_school_users, another_school))
    assert(ability.cannot?(:manage_school_students, another_school))

    assert(ability.can?(:create, InternshipAgreement))
    %i[create
      edit
      edit_activity_rating_rich_text
      edit_complementary_terms_rich_text
      edit_financial_conditions_rich_text
      edit_legal_terms_rich_text
      edit_main_teacher_full_name
      edit_school_representative_full_name
      edit_school_representative_phone
      edit_school_representative_email
      edit_school_representative_role
      edit_school_delegation_to_sign_delivered_at
      edit_student_refering_teacher_full_name
      edit_student_refering_teacher_email
      edit_student_refering_teacher_phone
      edit_student_address
      edit_student_class_room
      edit_student_full_name
      edit_student_phone
      edit_student_legal_representative_email
      edit_student_legal_representative_full_name
      edit_student_legal_representative_phone
      edit_student_legal_representative_2_email
      edit_student_legal_representative_2_full_name
      edit_student_legal_representative_2_phone
      edit_student_school
      see_intro
      update ].each do |dedicated_ability|
        assert(ability.can?(dedicated_ability, internship_agreement))
      end
    internship_agreement.update_columns(aasm_state: :validated)
    assert(ability.can?(:sign_internship_agreements, internship_agreement.reload), "Ability : Signature fails")
  end

  test 'MainTeacher' do
    student  = create(:student)
    school = student.school
    another_school = create(:school)
    school_manager = create(:school_manager, school: school)
    class_room = create(:class_room, school: school)
    main_teacher = create(:main_teacher, school: school, class_room: class_room)
    internship_application = create(:weekly_internship_application, student: student)
    internship_agreement   = create(:troisieme_generale_internship_agreement, :created_by_system,
                                    internship_application: internship_application)
    ability = Ability.new(main_teacher)

    assert(ability.can?(:welcome_students, main_teacher),
           'main_teacher are to be able to welcome students')
    assert(ability.can?(:choose_class_room, main_teacher),
           'student should be able to choose_class_room')
    assert(ability.can?(:choose_role, User))
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:subscribe_to_webinar, main_teacher))
    assert(ability.can?(:show, :account),
           'students should be able to access their account')

    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:change, :class_room))

    assert(ability.can?(:destroy, internship_application))
    assert(ability.can?(:update, internship_application))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.can?(:submit_internship_application, internship_application))
    assert(ability.can?(:validate_convention, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))

    assert(ability.can?(:see_tutor, InternshipOffer))

    assert(ability.can?(:manage_school_users, school))
    assert(ability.can?(:manage_school_students, school))
    assert(ability.can?(:choose_school, main_teacher),
          'student should be able to choose_school')
    assert(ability.can?(:manage_school_internship_agreements, school))
    assert(ability.cannot?(:create_remote_internship_request, school))

    assert(ability.cannot?(:manage_school_students, build(:school)))
    assert(ability.cannot?(%i[show edit update], School),
          'school_manager should be able manage school')
    assert(ability.cannot?(:manage_school_users, another_school))
    assert(ability.cannot?(:manage_school_students, another_school))
    refute(ability.can?(:sign_internship_agreements, internship_agreement.reload),
          "Ability : Signature should not be possible for teachers")
  end

  test 'Teacher' do
    school = create(:school, :with_school_manager)
    teacher = create(:teacher, school: school)
    ability = Ability.new(teacher)

    assert(ability.can?(:subscribe_to_webinar, teacher))
    assert(ability.can?(:welcome_students, teacher),
           'teacher are to be able to welcome students')
    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:see_tutor, InternshipOffer))
    assert(ability.can?(:manage_school_students, teacher.school))
    assert(ability.cannot?(:manage_school_students, build(:school)))
    assert(ability.can?(:change, :class_room))
  end

  test 'Other' do
    school = create(:school, :with_school_manager)
    another_school = create(:school)
    other = create(:other, school: school)
    ability = Ability.new(other)
    assert(ability.can?(:manage_school_students, other.school))
    assert(ability.cannot?(:manage_school_students, another_school))
    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:change, :class_room))
  end

  test 'Operator' do
    operator = create(:user_operator)
    ability = Ability.new(operator)

    assert(ability.can?(:supply_offers, operator),
           'operator are to be able to supply offers')
    assert(ability.can?(:create, InternshipOffers::Api.new),
           'Operator should be able to create internship_offers')
    assert(ability.cannot?(:update, InternshipOffers::Api.new),
           'Operator should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffers::Api.new(employer: operator)),
           'Operator should be able to update internships offer that belongs to him')
    assert(ability.can?(:index_and_filter, Reporting::InternshipOffer))
    assert(ability.can?(:index, Acl::Reporting.new(user: operator, params: {})))
    assert(ability.can?(:index, Acl::InternshipOfferDashboard.new(user: operator)),
           'Operator should be able to index InternshipOfferDashboard')

    refute(ability.can?(:create_remote_internship_request, SupportTicket),
          'operators are not supposed to fill forms for remote internships support')
  end
end
