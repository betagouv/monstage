require 'test_helper'

class SchoolManagerMailerTest < ActionMailer::TestCase
  test "new_main_teacher" do
    main_teacher = build(:main_teacher)
    school_manager = build(:school_manager)
    email = SchoolManagerMailer.new_main_teacher(main_teacher: main_teacher,
                                                 school_manager: school_manager)
    assert_includes email.to, school_manager.email
    assert_equal "Nouveau Profésseur Principal Signup: #{main_teacher.first_name} #{main_teacher.last_name}", email.subject
  end
end
