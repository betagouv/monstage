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

    test "i18n" do
      assert_equal "Chef d'établissement", SchoolManager.human_attribute_name(:school_manager)
    end

    test 'school_manager.after_sign_in_path without school or weeks redirects to account_path' do
      school_manager = build(:school_manager, school: nil)
      assert_equal(school_manager.after_sign_in_path,
                   Rails.application.routes.url_helpers.account_path)
    end

    test 'school_manager.after_sign_in_path with school and weeks redirects to dashboard_school_path' do
      school = create(:school, weeks: [Week.find_by(number: 1, year: 2019)])
      school_manager = create(:school_manager, school: school)
      redirect_to = Rails.application
                         .routes
                         .url_helpers
                         .dashboard_school_path(school_manager.school)
      assert_equal(redirect_to, school_manager.after_sign_in_path)
    end
  end
end
