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
      assert_includes errors, :school_manager
    end

    test "creation succeed" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = Users::MainTeacher.new(email: 'chef@ac-etablissement.com',
                                            password: 'tototo',
                                            password_confirmation: 'tototo',
                                            first_name: 'Chef',
                                            last_name: 'Etablissement',
                                            school: school)
      assert main_teacher.valid?
    end

    test "change school requires school_manager" do
      school_1 = create(:school)
      school_2 = create(:school)
      school_manager = create(:school_manager, school: school_1)
      main_teacher = create(:main_teacher, school: school_1)
      main_teacher.school = school_2
      assert_not main_teacher.valid?
      assert_includes main_teacher.errors.keys, :school_manager
    end


    test "school_manager" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)

      assert_equal main_teacher.school_manager, school_manager
    end

    test "i18n" do
      assert_equal "Chef d'établissement",
                   MainTeacher.human_attribute_name(:school_manager)
    end
  end
end
