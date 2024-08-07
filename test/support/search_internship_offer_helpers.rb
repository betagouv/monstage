module SearchInternshipOfferHelpers
  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_card_presence_of(internship_offer:)
    assert_selector "div[data-internship-offer-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  def fill_in_city_or_zipcode(with:, expect:)
    find('#input-search-by-city-or-zipcode').fill_in(with:)
    find('#downshift-1-item-0', wait: 4).click if with.size.positive?
    assert_equal expect,
                 find('#test-input-location-container #input-search-by-city-or-zipcode').value,
                 'click on list view does not fill location input'
  end

  def fill_in_keyword(keyword:)
    find('#input-search-by-keyword').fill_in(with: keyword[0..5])
    find('#test-input-keyword-container .listview-item').click if keyword.size.positive?
    assert_equal keyword,
                 find('#test-input-keyword-container #input-search-by-keyword').value,
                 'click on list view does not fill keyword input'
  end

  def fill_in_week(week:, open_popover:)
    within ".form-group[data-search-popover-target='searchByDateContainer']" do
      find('label', text: 'Dates de stage').click
    end
    find('#input-search-by-week').click if open_popover
    execute_script("document.getElementById('checkbox_#{week.id}').checked = true;")
  end
end
