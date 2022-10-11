# frozen_string_literal: true

require 'test_helper'
module Users
  class SchoolManagementTest < ActiveSupport::TestCase
    setup do
      @url_helpers = Rails.application.routes.url_helpers
    end

    test 'creation fails (school_manager requires an .ac ending mail' do
      school_manager = Users::SchoolManagement.new(
        role: :school_manager,
        email: 'chef@etablissement.com',
        school: create(:school)
      )

      assert school_manager.invalid?
      assert_not_empty school_manager.errors[:email]
    end

    test 'validates other fields' do
      school_manager = Users::SchoolManagement.new(role: :teacher)

      assert school_manager.invalid?
      assert_not_empty school_manager.errors[:first_name]
      assert_not_empty school_manager.errors[:last_name]
      assert_not_empty school_manager.errors[:email]
      assert_not_empty school_manager.errors[:accept_terms]
      assert_not_empty school_manager.errors[:password]
    end

    test 'creation succeed' do
      school = build(:school)
      school_manager = Users::SchoolManagement.new(
        role: :school_manager,
        email: "jean-pierre@#{school.email_domain_name}",
        password: 'tototo',
        password_confirmation: 'tototo',
        first_name: 'Chef',
        last_name: 'Etablissement',
        phone: '+330602030405',
        school: school,
        accept_terms: true
      )
      assert school_manager.valid?
    end

    test 'has_many main_teachers' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      main_teacher = create(:main_teacher, school: school)

      school_manager.reload

      assert_includes school_manager.main_teachers.entries, main_teacher
    end

    test 'school_managemennt.after_sign_in_path with school but no weeks redirects to account_path' do
      school_manager = create(:school_manager, school: create(:school, weeks: []))
      assert_equal(school_manager.after_sign_in_path,
                   @url_helpers.edit_dashboard_school_path(school_manager.school))
    end

    test 'school_manager.after_sign_in_path with school and weeks redirects to dashboard_school_path' do
      school = create(:school, weeks: [Week.find_by(number: 1, year: 2019)])
      school_manager = create(:school_manager, school: school)
      redirect_to = @url_helpers.dashboard_school_path(school_manager.school)
      assert_equal(redirect_to, school_manager.after_sign_in_path)
    end

    test 'teacher.after_sign_in_path with school redirects to dashboard_school_class_room_path when class_room exists' do
      school = create(:school, weeks: [Week.find_by(number: 1, year: 2020)])
      class_room = create(:class_room, school: school)
      school_manager = create(:school_manager, school: school, class_room: class_room)
      redirect_to = @url_helpers.dashboard_school_class_room_students_path(school, class_room)
      assert_equal(redirect_to, school_manager.after_sign_in_path)
    end

    test 'change school notify new school_manager' do
      school_1 = create(:school)
      school_2 = create(:school)
      school_manager_1 = create(:school_manager, school: school_1)
      school_manager_2 = create(:school_manager, school: school_2)

      %i[teacher other main_teacher].each do |role_change_notifier|
        user = create(role_change_notifier, school: school_1)
        user.school = school_2

        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        SchoolManagerMailer.stub :new_member, mock_mail do
          user.save!
        end
        mock_mail.verify
      end
    end

    test '#custom_dashboard_path as main_teacher' do
      school = create(:school, :with_school_manager, weeks: [Week.find_by(number: 1, year: 2020)])
      class_room = create(:class_room, school: school)
      main_teacher = create(:main_teacher, school: school, class_room: class_room)
      assert_equal @url_helpers.dashboard_school_class_room_students_path(school, class_room), main_teacher.custom_dashboard_path
    end
  end
end

