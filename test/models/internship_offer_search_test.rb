# frozen_string_literal: true

require 'test_helper'

class InternshipOfferSearchTest < ActiveSupport::TestCase
  setup do
    keywords = %w[test docteur veterinaire]
    keywords.map { |keyword| FactoryBot.create(:internship_offer, title: 'keyword') }
  end

  test 'search_by_term works' do
    assert_nothing_raised do
      query = InternshipOffer.search_by_term("test")
                             .group(:id)
                             .page(1)
    end
  end
end
