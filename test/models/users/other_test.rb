require 'test_helper'
module Users
  class OtherTest < ActiveSupport::TestCase
    test "creation fails" do
      other = Users::Other.create()
      assert other.invalid?
      errors = other.errors.keys
      assert_includes errors, :school
      assert_includes errors, :first_name
      assert_includes errors, :last_name
      assert_includes errors, :email
      assert_includes errors, :school_manager
    end

    test "creation succeed" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      other = Users::Other.new(email: 'chef@ac-etablissement.com',
                                            password: 'tototo',
                                            password_confirmation: 'tototo',
                                            first_name: 'Chef',
                                            last_name: 'Etablissement',
                                            school: school)
      assert other.valid?
    end
    test "send SchoolManagerMailer.new_member on create" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)
      SchoolManagerMailer.stub :new_member, mock_mail do
        create(:other, school: school)
      end
      mock_mail.verify
    end

    test "change school requires school_manager" do
      school_1 = create(:school)
      school_manager_1 = create(:school_manager, school: school_1)
      other = create(:other, school: school_1)

      other.school = create(:school)
      assert_not other.valid?
      assert_includes other.errors.keys, :school_manager

      school_manager_2 = create(:school_manager, school: other.school)
      other.reload
      other.school = school_manager_2.school
      assert other.valid?

      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)
      SchoolManagerMailer.stub :new_member, mock_mail do
        other.save!
      end
      mock_mail.verify
    end


    test "school_manager" do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      other = create(:other, school: school)

      assert_equal other.school_manager, school_manager
    end

    test "i18n" do
      assert_equal "Chef d'établissement",
                   Other.human_attribute_name(:school_manager)
    end
  end
end
