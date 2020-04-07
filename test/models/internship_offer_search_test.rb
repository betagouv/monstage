# frozen_string_literal: true

require 'test_helper'

class InternshipOfferSearchTest < ActiveSupport::TestCase
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
    SyncInternshipOfferKeywordsJob.perform_now
  end

  def iterate_word(word, &block)
    word.split('').each.with_index do |_char, i|
      next if i < 2
      yield(word[0..i])
    end
  end

  test 'search_by_term does not raise an error' do
    assert_nothing_raised do
      query = InternshipOffer.search_by_term("test").group(:id).page(1)
    end
  end

  test 'search by term find by simple word' do
    iterate_word('docteur') do |word_part|
      assert_equal(1,
                   InternshipOffer.search_by_term(word_part).count,
                   "can't find with #{word_part}")
    end
  end

  test 'search by term find by synonym' do
    assert_equal(2,
                 InternshipOffer.search_by_term("police").count,
                 "can't find with synonym police")
    assert_equal(2,
                 InternshipOffer.search_by_term("gendarme").count,
                 "can't find with synonym gendarme")
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
