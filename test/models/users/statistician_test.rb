require 'test_helper'
module Users
  class StatisticianTest < ActiveSupport::TestCase
    test 'creation fails' do
      statistician = Users::Statistician.new(email: 'chef@etablissement.com',
                                             password: 'tototo',
                                             password_confirmation: 'tototo',
                                             first_name: 'Chef',
                                             last_name: 'Departement',
                                             accept_terms: true)

      assert statistician.invalid?
      assert_not_empty statistician.errors[:email]
    end

    test 'creation succeed' do
      whitelisted_email = create(:email_whitelist,
                                 email: 'white@list.email',
                                 zipcode: '60')
      statistician = Users::Statistician.new(email: whitelisted_email.email,
                                             password: 'tototo',
                                             password_confirmation: 'tototo',
                                             first_name: 'Chef',
                                             last_name: 'Departement',
                                             accept_terms: true)
      assert statistician.valid?
    end

    test 'departement_name' do
      whitelisted_email = create(:email_whitelist,
                                 email: 'fourcade.m@gmail.com',
                                 zipcode: '59')

      statistician = create(:statistician, email: whitelisted_email.email)
      assert_equal 'Nord (département français)|Nord', statistician.department_name
    end
  end
end
