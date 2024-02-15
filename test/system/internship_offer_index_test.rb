# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferIndexTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  test 'navigation & interaction works' do
    school = create(:school)
    student = create(:student, school: school)
    internship_offer = create(:weekly_internship_offer)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit internship_offers_path

        # assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'pagination of internship_offers index is ok with api or weekly offers' do
    travel_to Date.new(2022, 9, 1) do
      2.times do
        create(:weekly_internship_offer, city: 'Chatillon', coordinates: Coordinates.chatillon)
      end
      (InternshipOffer::PAGE_SIZE/2).times do
        create(:weekly_internship_offer, city: 'Paris', coordinates: Coordinates.paris, zipcode: '75000')
        create(:api_internship_offer, city: 'Paris', coordinates: Coordinates.paris, zipcode: '75000')
      end
      student = create(:student)
      assert_equal 'Paris', student.school.city
      sign_in(student)
      visit internship_offers_path
      find("li a.fr-link", text: 'Recherche').click
      within(".fr-test-internship-offers-container") do
        assert_selector('.fr-card__desc p.blue-france', text: 'Paris', count: InternshipOffer::PAGE_SIZE, wait: 5)
      end

      click_link 'Page suivante'
      within(".fr-test-internship-offers-container") do
        assert_selector('.fr-card__desc p.blue-france', text: 'Chatillon', count: 2, wait: 2)
      end
    end
  end

  test 'recommandation is shown when no offer is available' do
    travel_to Date.new(2022, 9, 1) do
      2.times do
        create(:weekly_internship_offer, city: 'Montmorency', coordinates: Coordinates.montmorency)
      end
      student = create(:student)
      assert_equal 'Paris', student.school.city
      sign_in(student)
      visit internship_offers_path(latitude: 48.8589, longitude: 2.347, city:"paris", radius:5_000)
      # there are no offers in Paris
      find 'h6', text: "Aucune offre trouvée..."
      within(".fr-test-internship-offers-container") do
        assert_selector('.fr-card__desc p.blue-france', text: 'Montmorency', count: 2, wait: 2)
      end
    end
  end
end
