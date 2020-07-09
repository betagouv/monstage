# frozen_string_literal: true

require 'test_helper'

module InternshipsOffers
  class FreeDateTest < ActiveSupport::TestCase
    test 'default max_candidates' do
      assert_equal 1, InternshipOffers::FreeDate.new.max_candidates
      assert_equal 1, InternshipOffers::FreeDate.new(max_candidates: '').max_candidates
    end

    test 'sync_first_and_last_date on create' do
      internship_offer = create(:free_date_internship_offer)
      assert_not_nil internship_offer.first_date
      assert_not_nil internship_offer.last_date
    end
  end
end
