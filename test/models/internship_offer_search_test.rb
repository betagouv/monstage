# frozen_string_literal: true

require 'test_helper'

class InternshipOfferSearchTest < ActiveSupport::TestCase
  include ::ApiTestHelpers
  setup do
    FactoryBot.create(:internship_offer,
                      title: 'docteur',
                      description: 'stage dans un xxx',
                      employer_description: '')
    FactoryBot.create(:internship_offer,
                      title: 'police',
                      description: 'stage dans un xxx',
                      employer_description: '')
    FactoryBot.create(:internship_offer,
                      title: 'gendarme',
                      description: 'stage dans une xxx',
                      employer_description: '')
    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
  end

  def iterate_word(word, &block)
    word.split('').each.with_index do |_char, i|
      next if i < 2
      yield(word[0..i])
    end
  end

  test 'search_by_keyword does not raise an error' do
    assert_nothing_raised do
      query = InternshipOffer.search_by_keyword("test").group(:id).page(1)
    end
  end

  test 'search by term find by simple word' do
    iterate_word('docteur') do |word_part|
      assert_equal(1,
                   InternshipOffer.search_by_keyword(word_part).count,
                   "can't find with #{word_part}")
    end
  end

  test 'search by term find by synonym' do
    assert_equal(2,
                 InternshipOffer.search_by_keyword("police").count,
                 "can't find with synonym police")
    assert_equal(2,
                 InternshipOffer.search_by_keyword("gendarme").count,
                 "can't find with synonym gendarme")
  end
end
