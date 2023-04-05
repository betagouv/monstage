# frozen_string_literal: true

require 'test_helper'

class SchoolManagerMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'new_member' do
    main_teacher = build(:main_teacher)
    school_manager = create(:school, :with_school_manager).school_manager
    email = SchoolManagerMailer.new_member(member: main_teacher,
                                           school_manager: school_manager)
    assert_includes email.to, school_manager.email
    assert_equal "Nouveau Professeur principal: #{main_teacher.first_name} #{main_teacher.last_name}", email.subject
    refute_email_spammyness(email)
  end

  test 'internship_application_approved_with_agreement_email' do
    internship_agreement = create(:internship_agreement)
    school_manager = internship_agreement.internship_application.student.school.school_manager
    email = SchoolManagerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    assert_includes email.to, school_manager.email
    assert_equal 'Une convention de stage sera bientôt disponible.', email.subject
    refute_email_spammyness(email)
  end

  test 'internship_application_with_no_agreement_email within troisieme generale context' do
    school = create(:school, :with_school_manager, :with_weeks)
    student = create(:student_with_class_room_3e, school: school)
    internship_offer = create(:internship_offer, weeks: school.weeks)
    internship_application = create(:internship_application,
                                    :approved,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    main_teacher = create(:main_teacher, class_room: school.class_rooms.first, school: school)
    school_manager = school.school_manager
    # internship_application.approve!
    email = SchoolManagerMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
    assert_includes email.to, school_manager.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

  test 'internship_application_with_no_agreement_email within troisieme generale context but no class_room' do
    school = create(:school, :with_school_manager, :with_weeks)
    student = create(:student_with_class_room_3e, school: school)
    internship_offer = create(:internship_offer, weeks: school.weeks)
    internship_application = create(:internship_application,
                                    :submitted,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    school_manager = school.school_manager
    main_teacher = nil
    internship_application.approve!
    email = SchoolManagerMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
    assert_includes email.to, school_manager.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

  test 'signatures : notify_others_signatures_started_email' do
    internship_agreement = create(:internship_agreement, :validated)
    school_manager = internship_agreement.school_manager
    email = SchoolManagerMailer.notify_others_signatures_started_email(
      internship_agreement: internship_agreement
    )
    assert_includes email.to, school_manager.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

  test 'signatures : notify_others_signatures_finished_email' do
    internship_agreement = create(:internship_agreement, :validated)
    school_manager = internship_agreement.school_manager
    email = SchoolManagerMailer.notify_others_signatures_finished_email(
      internship_agreement: internship_agreement
    )
    assert_includes email.to, school_manager.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end
end
