# frozen_string_literal: true

require 'test_helper'

class SchoolSearchTest < ActiveSupport::TestCase
  test 'autocomplete_by_name_or_city find stuffs upper or lower case' do
    paris = create(:api_school, city: 'Paris')
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'PARIS').size, 'find with uppercase fails'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'paris').size, 'find with lowercase fails'
  end

  test 'autocomplete_by_name_or_city find with or without accent' do
    orleans = create(:api_school, city: 'Orléans')

    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Orléans').size, 'find with accent'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Orleans').size, 'find without accent'
  end

  test 'pg_search_highlight_*' do
    school_city = 'Orléans'
    school_name = 'Jean'
    orleans = create(:api_school, city: school_city,
                                   name: school_name)

    search_by_city_result = Api::School.autocomplete_by_name_or_city(term: school_city).first
    assert_equal "<b>#{school_city}</b>", search_by_city_result.pg_search_highlight_city
    search_by_name_result = Api::School.autocomplete_by_name_or_city(term: school_name).first
    assert_equal "<b>#{school_name}</b>", search_by_name_result.pg_search_highlight_name
  end

  test 'autocomplete_by_name_or_city find compound cities names' do
    orleans = create(:api_school, city: 'Mantes-la-Jolie')

    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Mante').size, 'coumpound with missing letter missed'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Mantes').size, 'compound with single complete word missed'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Mantes-la').size, 'compound halfly spelled with dashes missed'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Mantes-la-Jolie').size, 'compound fully spelled with dashes missed'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Mantes-la-Jolie').size, 'compound fully spelled without dashes missed'
    assert_equal 1, Api::School.autocomplete_by_name_or_city(term: 'Mantes Jolie').size, 'compound with missing stop word missed'
  end

  test 'autocomplete_by_name_or_city returns ordered result (by Levenshtein distance on city.name)' do
    paris = create(:api_school, city: 'Paris')
    parisot = create(:api_school, city: 'Parisot')
    parisote = create(:api_school, city: 'Parisote')
    parisotel = create(:api_school, city: 'Parisotel')

    results = Api::School.autocomplete_by_name_or_city(term: 'Pari')

    assert_equal paris.name, results[0].name
    assert_equal parisot.name, results[1].name
    assert_equal parisote.name, results[2].name
    assert_equal parisotel.name, results[3].name
  end

  test 'autocomplete_by_name_or_city return pg_search_highlight' do
    create(:api_school, city: 'paris')
    create(:api_school, city: 'paris blip')
    results = Api::School.autocomplete_by_name_or_city(term: 'pari')
    assert '<b>paris</b>', results[0].attributes['pg_search_highlight']
    assert '<b>paris</b> blip', results[1].attributes['pg_search_highlight']
  end

  test 'autocomplete_by_name_or_city find by increment, even with stop words' do
    city = 'paris'
    create(:api_school, city: city)
    city.split('').each.with_index do |_, idx|
      query_part = city[0..idx]
      results = Api::School.autocomplete_by_name_or_city(term: query_part)
      assert_equal 1, results.size, "fail to find with '#{query_part}'"
      assert_equal city, results[0].city
    end
  end
end
