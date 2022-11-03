# frozen_string_literal: true

require 'test_helper'
module Users
  class EmployerTest < ActiveSupport::TestCase
    test 'employer.after_sign_in_path redirects to internship_offers_path' do
      employer = build(:employer)
      assert_equal(employer.after_sign_in_path,
                   Rails.application.routes.url_helpers.dashboard_internship_offers_path)
    end

    test '(rails6.1 upgrade) employer.kept_internship_offers' do
      employer = create(:employer)
      kept_internship_offer = create(:weekly_internship_offer, employer: employer)
      discarded_internship_offer = create(:weekly_internship_offer, employer: employer)
      discarded_internship_offer.discard

      assert_equal 1, employer.kept_internship_offers.count
      assert_includes employer.kept_internship_offers, kept_internship_offer
      refute_includes employer.kept_internship_offers, discarded_internship_offer
    end

    test '#obfuscated_phone_number' do
      employer = build(:employer, phone: '+330601020304')
      assert_equal '+33 6 ** ** ** 04', employer.obfuscated_phone_number
    end

    test '(rails6.1 upgrade) employer.internship_applications' do
      employer = create(:employer)
      kept_internship_offer = create(:weekly_internship_offer, employer: employer)
      discarded_internship_offer = create(:weekly_internship_offer, employer: employer)
      kept_internship_application = create(:weekly_internship_application, internship_offer: kept_internship_offer)
      discarded_internship_application = create(:weekly_internship_application, internship_offer: discarded_internship_offer)

      discarded_internship_offer.discard

      assert_equal 1, employer.internship_applications.count
      assert_includes employer.internship_applications, kept_internship_application
      refute_includes employer.internship_applications, discarded_internship_application
    end

    test '#already_signed?' do
      internship_agreement_1 = create(:internship_agreement)
      internship_agreement_2 = create(:internship_agreement)
      employer = internship_agreement_1.employer
      refute employer.already_signed?(internship_agreement_id: internship_agreement_1.id)
      refute employer.already_signed?(internship_agreement_id: internship_agreement_2.id)
      create(:signature,
             internship_agreement: internship_agreement_1,
             signatory_role: :employer,
             user_id: employer.id
            )
      assert employer.already_signed?(internship_agreement_id: internship_agreement_1.id)
      refute employer.already_signed?(internship_agreement_id: internship_agreement_2.id)
    end
  end
end
