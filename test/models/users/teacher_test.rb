require 'test_helper'
module Users
  class TeacherTest < ActiveSupport::TestCase
    test "creation fails" do
      teacher = Users::Teacher.create()
      assert teacher.invalid?
      errors = teacher.errors.keys
      assert_includes errors, :school
      assert_includes errors, :first_name
      assert_includes errors, :last_name
      assert_includes errors, :email
      assert_includes errors, :school_manager
    end

    test "creation succeed" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      teacher = Users::Teacher.new(email: 'chef@ac-etablissement.com',
                                            password: 'tototo',
                                            password_confirmation: 'tototo',
                                            first_name: 'Chef',
                                            last_name: 'Etablissement',
                                            school: school)
      assert teacher.valid?
    end

    test "send SchoolManagerMailer.new_member on create" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)
      SchoolManagerMailer.stub :new_member, mock_mail do
        create(:teacher, school: school)
      end
      mock_mail.verify
    end

    test 'school can be nullified' do
      school_1 = create(:school)
      school_manager_1 = create(:school_manager, school: school_1)
      teacher = create(:teacher, school: school_1)

      teacher.school = create(:school)
      assert teacher.valid?
    end

    test "change school notify new school_manager" do
      school_1 = create(:school)
      school_2 = create(:school)
      school_manager_1 = create(:school_manager, school: school_1)
      school_manager_2 = create(:school_manager, school: school_2)
      teacher = create(:teacher, school: school_1)

      teacher.school = school_2
      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)
      SchoolManagerMailer.stub :new_member, mock_mail do
        teacher.save!
      end
      mock_mail.verify
    end

    test "school_manager" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      teacher = create(:teacher, school: school)

      assert_equal teacher.school_manager, school_manager
    end

    test "i18n" do
      assert_equal "Chef d'établissement",
                   Teacher.human_attribute_name(:school_manager)
    end
  end
end
