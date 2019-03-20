require 'test_helper'
module Users
  class MainTeacherTest < ActiveSupport::TestCase
    test "creation fails" do
      main_teacher = Users::MainTeacher.create()
      assert main_teacher.invalid?
      errors = main_teacher.errors.keys
      assert_includes errors, :school
      assert_includes errors, :first_name
      assert_includes errors, :last_name
      assert_includes errors, :email
    end

    test "creation succeed" do
      main_teacher = Users::MainTeacher.new(email: 'chef@ac-etablissement.com',
                                            password: 'tototo',
                                            password_confirmation: 'tototo',
                                            first_name: 'Chef',
                                            last_name: 'Etablissement',
                                            school: build(:school))
      assert main_teacher.valid?
    end


    test "school_manager" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)

      assert_equal main_teacher.school_manager, school_manager
    end
  end
end
