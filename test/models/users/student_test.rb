# frozen_string_literal: true

require 'test_helper'
module Users
  class StudentTest < ActiveSupport::TestCase
    test 'student.after_sign_in_path redirects to internship_offers_path' do
      student = create(:student)
      assert_equal(student.after_sign_in_path,
                   Presenters::User.new(student).default_internship_offers_path,
                   'failed to use default_internship_offers_path for user without targeted_offer_id')

      student.targeted_offer_id= 1
      assert_equal(student.after_sign_in_path,
                   Rails.application.routes.url_helpers.internship_offer_path(id: 1))

    end

    test 'validate wrong mobile phone format' do
      user = build(:student, phone: '+330111223344')
      refute user.valid?
      assert_equal ['Veuillez modifier le numéro de téléphone mobile'], user.errors.messages[:phone]
    end

    test 'validate wrong phone format' do
      user = build(:student, phone: '06111223344')
      refute user.valid?
      assert_equal ['Veuillez modifier le numéro de téléphone mobile'], user.errors.messages[:phone]
    end

    test 'validate good phone format' do
      user = build(:student, phone: '+330611223344')
      assert user.valid?
    end

    test 'no phone token creation after user creation' do
      user = create(:student, phone: '')
      assert_nil user.phone_token
      assert_nil user.phone_token_validity
    end

    test 'phone token creation after user creation' do
      user = create(:student, phone: '+330711223344')
      assert_not_nil user.phone_token
      assert_equal 4, user.phone_token.size
      assert_not_nil user.phone_token_validity
      assert_equal true, user.phone_token_validity.between?(59.minutes.from_now, 61.minutes.from_now)
    end
  end
end
