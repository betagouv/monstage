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

  test 'agreement_creation_notice_email' do
    internship_agreement = create(:internship_agreement)
    school_manager = internship_agreement.internship_application.student.school.school_manager
    email = SchoolManagerMailer.agreement_creation_notice_email(
      internship_agreement: internship_agreement
    )
    assert_includes email.to, school_manager.email
    assert_equal 'Une convention de stage sera bientôt disponible.', email.subject
    refute_email_spammyness(email)
  end

end
