# frozen_string_literal: true

require 'test_helper'

class SchoolManagerMailerTest < ActionMailer::TestCase
  test 'new_member' do
    main_teacher = build(:main_teacher)
    school_manager = build(:school_manager)
    email = SchoolManagerMailer.new_member(member: main_teacher,
                                           school_manager: school_manager)
    assert_includes email.to, school_manager.email
    assert_equal "Nouveau Professeur principal: #{main_teacher.first_name} #{main_teacher.last_name}", email.subject
  end

  test 'missing_school_weeks' do
    school = create(:school, :with_school_manager)

    email = SchoolManagerMailer.missing_school_weeks(school_manager: school.school_manager)
    assert_includes email.to, school.school_manager.email
    assert_equal "Action requise – Renseignez les semaines de stage de votre établissement", email.subject
  end
end
