require 'test_helper'
module Users
  class SchoolManagerTest < ActiveSupport::TestCase
    test "creation fails" do
      school_manager = Users::SchoolManager.new(email: 'chef@etablissement.com',
                                                password: 'tototo',
                                                password_confirmation: 'tototo',
                                                first_name: 'Chef',
                                                last_name: 'Etablissement',
                                                school: build(:school))

      assert school_manager.invalid?
      assert_not_empty school_manager.errors[:email]
    end

    test 'creation succeed' do
      school_manager = Users::SchoolManager.new(email: 'chef@ac-etablissement.com',
                                                password: 'tototo',
                                                password_confirmation: 'tototo',
                                                first_name: 'Chef',
                                                last_name: 'Etablissement',
                                                school: build(:school))
      assert school_manager.valid?
    end

    test 'has_many main_teachers' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)

      school_manager.reload

      assert_includes school_manager.main_teachers.entries, main_teacher
    end
  end
end
