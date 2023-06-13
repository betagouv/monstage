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


  test 'internship_agreement_completed_by_employer_email within troisieme generale context but no class_room' do
    internship_agreement = create(:internship_agreement, :started_by_employer)
    school_manager = internship_agreement.school_manager
    email = SchoolManagerMailer.internship_agreement_completed_by_employer_email(
      internship_agreement: internship_agreement
    )
    assert_includes email.to, school_manager.email
    assert_equal 'Vous avez une convention de stage à renseigner.', email.subject
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
