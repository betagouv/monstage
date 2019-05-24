# frozen_string_literal: true

require 'test_helper'
module Users
  class OtherTest < ActiveSupport::TestCase
    test 'creation fails' do
      other = Users::Other.new
      assert other.invalid?
      errors = other.errors.keys
      assert_includes errors, :school
      assert_includes errors, :first_name
      assert_includes errors, :last_name
      assert_includes errors, :email
    end

    test 'creation succeed' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      other = Users::Other.new(email: 'chef@lol.com',
                               password: 'tototo',
                               password_confirmation: 'tototo',
                               first_name: 'Chef',
                               last_name: 'Etablissement',
                               school: school)
      assert other.valid?
    end

    test 'send SchoolManagerMailer.new_member on create' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)
      SchoolManagerMailer.stub :new_member, mock_mail do
        create(:other, school: school)
      end
      mock_mail.verify
    end

    test 'school can be nullified' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      other = create(:other, school: school)

      other.school = nil
      assert other.valid?
    end

    test 'change school notify new other' do
      school_1 = create(:school)
      school_manager_1 = create(:school_manager, school: school_1)
      school_2 = create(:school)
      school_manager_2 = create(:school_manager, school: school_2)
      other_1 = create(:other, school: school_1)
      other_2 = create(:other, school: school_2)
      other = create(:other, school: school_1)

      other.school = school_2
      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)
      SchoolManagerMailer.stub :new_member, mock_mail do
        other.save!
      end
      mock_mail.verify
    end

    test 'i18n' do
      assert_equal 'Autres fonctions', Other.human_attribute_name(:other)
    end

    test 'other.after_sign_in_path without school redirects to account_path' do
      other = build(:other, school: nil)
      assert_equal(other.after_sign_in_path,
                   Rails.application.routes.url_helpers.account_path)
    end

    test 'other.after_sign_in_path with school and weeks redirects to dashboard_school_path' do
      school = create(:school, weeks: [Week.find_by(number: 1, year: 2019)])
      school_manager = create(:school_manager, school: school)
      other = create(:other, school: school)
      redirect_to = Rails.application
                         .routes
                         .url_helpers
                         .dashboard_school_class_rooms_path(other.school)
      assert_equal(redirect_to, other.after_sign_in_path)
    end
  end
end
