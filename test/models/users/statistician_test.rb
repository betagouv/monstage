# frozen_string_literal: true

require 'test_helper'

module Users
  class StatisticianTest < ActiveSupport::TestCase
    test 'creation fails' do
      statistician = Users::PrefectureStatistician.new(email: 'chef@etablissement.com',
                                             password: 'tototo',
                                             first_name: 'Chef',
                                             last_name: 'Departement',
                                             accept_terms: true)

      assert statistician.invalid?
      assert_not_empty statistician.errors[:department]
    end

    test 'creation succeed' do
      statistician = Users::PrefectureStatistician.new(email: 'test@free.fr',
                                             password: 'tototo',
                                             first_name: 'Chef',
                                             last_name: 'Departement',
                                             department: '75',
                                             accept_terms: true)
      assert statistician.valid?
    end

    test 'departement_name' do
      statistician = create(:education_statistician)
      assert_equal '60', statistician.department
    end

    test 'active scope' do
      statistician = create(:statistician)
      statistician2 = create(:statistician, discarded_at: 1.minute.ago)
      assert_equal Users::PrefectureStatistician.active.count, 1
    end
  end
end
