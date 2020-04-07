# frozen_string_literal: true

require 'test_helper'

class InternshipOfferSearchTest < ActiveSupport::TestCase
  setup do
    keywords = %w[test docteur veterinaire]
    keywords.map { |keyword| FactoryBot.create(:internship_offer, title: 'keyword') }
  end

  test 'search_by_term does not raise an error' do
    assert_nothing_raised do
      query = InternshipOffer.search_by_term("test")
                             .group(:id)
                             .page(1)
    end
  end

  test 'search by term find by simple word' do
    assert false
  end

  test 'search by term find by synonym' do
    assert false
  end

  test 'create sync keywords' do
    assert false
  end

  test 'destroy sync keywords' do
    assert false
  end

  test 'update sync keywords' do
    assert false
  end
end
