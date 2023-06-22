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

  test 'navigation & interaction works for employer' do
    employer = create(:employer)
    old_internship_offer = nil
    travel_to Date.new(2020, 10, 1) do
      old_internship_offer = create(:weekly_internship_offer, employer: employer)
    end
    travel_to Date.new(2021, 10, 1) do
      internship_offer = create(:weekly_internship_offer, employer: employer)

      sign_in(employer)

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          visit dashboard_internship_offers_path

          assert_presence_of(internship_offer: internship_offer)
          assert_presence_of(internship_offer: old_internship_offer)

          within("#toggle_status_internship_offers_weekly_framed_#{internship_offer.id}") do
            find(".label", text: "Publié")
          end
          within("#toggle_status_internship_offers_weekly_framed_#{old_internship_offer.id}") do
            find(".label", text: "Publié")
          end

          InternshipOffers::WeeklyFramed.archive_older_internship_offers

          visit dashboard_internship_offers_path

          within("#toggle_status_#{dom_id(internship_offer)}") do
            find(".label", text: "Publié")
          end
          within("#toggle_status_#{dom_id(old_internship_offer)}") do
            find(".label", text: "Masqué")
          end
        end
      end
    end
  end

  test 'tabs test(still todo)' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    sign_in(employer)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit dashboard_internship_offers_path

      end
    end
  end

  test 'unpublish navigation' do
    travel_to Date.new(2021, 10, 1) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer, weeks: [Week.next])
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          assert internship_offer.published?
          InternshipOffers::WeeklyFramed.archive_older_internship_offers
          assert internship_offer.reload.published?
          visit dashboard_internship_offers_path
          within("#toggle_status_#{dom_id(internship_offer)}") do
            find(".label", text: "Publié")
            find("a[rel='nofollow'][data-method='patch']").click # this unpublishes the internship_offer
          end

          find("h2.h4", text: "Les offres")

          within("#toggle_status_#{dom_id(internship_offer.reload)}") do
            find(".label", text: "Masqué")
          end
          refute internship_offer.reload.published?
        end
      end
    end
  end

  test 'publish navigation when no updates are necessary' do
    travel_to Date.new(2021, 10, 1) do
      employer = create(:employer)
      within_2_weeks = Week.find_by(id: Week.current.id + 2)
      internship_offer = create(:weekly_internship_offer, employer: employer, weeks: [within_2_weeks])
      internship_offer.unpublish!
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          refute internship_offer.published?
          visit dashboard_internship_offers_path
          within("#toggle_status_#{dom_id(internship_offer)}") do
            find(".label", text: "Masqué")
            find("a[rel='nofollow'][data-method='patch']").click # this publishes the internship_offer
          end

          find("h2.h4", text: "Les offres")

          within("#toggle_status_#{dom_id(internship_offer.reload)}") do
            find(".label", text: "Publié")
          end
          assert internship_offer.reload.published?
        end
      end
    end
  end

  test 'publish navigation when week updates are necessary' do
    employer = create(:employer)
    internship_offer = nil
    travel_to Date.new(2021, 10, 1) do
      internship_offer = create(:weekly_internship_offer, employer: employer, weeks: [Week.next])
      internship_offer.unpublish!
    end
    travel_to Date.new(2022, 10, 8) do
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          refute internship_offer.published?
          visit dashboard_internship_offers_path
          within("#toggle_status_#{dom_id(internship_offer)}") do
            find(".label", text: "Masqué")
            find("label.fr-toggle__label[for='toggle-#{internship_offer.id}']") # this publishes the internship_offer
            execute_script("document.getElementById('axe-toggle-#{internship_offer.id}').closest('form').submit()")
          end

          refute internship_offer.reload.published?

          find "h1.h2", text: "Modifier une offre de stage"
          find "span#alert-text", text: "Votre annonce n'est pas encore republiée, car il faut ajouter des semaines de stage"

          # find('h3.fr-alert__title', text: 'Ajoutez des semaines aux précédentes')

          find('label', text: 'Semaine 41 - du 11 octobre au 17 octobre 2021').click
        end
      end
    end
  end

  test 'publish navigation when max_candidates updates are necessary' do
    employer = create(:employer)
    internship_offer = nil
    travel_to Date.new(2021, 10, 1) do
      within_2_weeks = Week.find_by(id: (Week.current.id + 2))
      within_1_year = Week.find_by(id: (Week.current.id + 54))
      internship_offer = create(:weekly_internship_offer, max_candidates: 1, employer: employer, weeks: [within_2_weeks, within_1_year])
      create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_offer.unpublish!
    end
    travel_to Date.new(2022, 9, 1) do
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          refute internship_offer.published?
          visit dashboard_internship_offers_path
          within("#toggle_status_#{dom_id(internship_offer)}") do
            find(".label", text: "Masqué")
            find("label.fr-toggle__label[for='toggle-#{internship_offer.id}']") # this publishes the internship_offer
            execute_script("document.getElementById('axe-toggle-#{internship_offer.id}').closest('form').submit()")
          end

          refute internship_offer.reload.published?

          find "h1.h2", text: "Modifier une offre de stage"
          find "span#alert-text", text: "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage"

          # find('h3.fr-alert__title', text: 'Ajoutez des places pour ce stage')
        end
      end
    end
  end
end
