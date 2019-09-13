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
      statistician = Users::Statistician.new(email: 'fourcade.m@gmail.com',
                                             password: 'tototo',
                                             password_confirmation: 'tototo',
                                             first_name: 'Chef',
                                             last_name: 'Departement',
                                             accept_terms: true)
      assert statistician.valid?
    end

    test 'departement_name' do
      statistician = create(:statistician)
      assert_equal 'Oise', statistician.department_name
    end
  end
end
