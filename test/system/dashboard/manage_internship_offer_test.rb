# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def wait_form_submitted
    find('.alert-sticky')
  end

  def fill_in_trix_editor(id, with:)
    find(:xpath, "//trix-editor[@id='#{id}']").click.set(with)
  end

  test 'can edit internship offer' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    sign_in(employer)
    visit edit_dashboard_internship_offer_path(internship_offer)
    find('input[name="internship_offer[employer_name]"]').fill_in(with: 'NewCompany')

    click_on "Modifier l'offre"
    wait_form_submitted
    assert /NewCompany/.match?(internship_offer.reload.employer_name)
  end

  test 'can edit school_track of an internship offer back and forth' do
    employer = create(:employer)
    internship_offer = create(:bac_pro_internship_offer, employer: employer)
    internship_offer_id = internship_offer.id
    sign_in(employer)
    visit edit_dashboard_internship_offer_path(internship_offer)
    select '3ème', from: 'Filière cible'
    find("label[for='all_year_long']").click
    fill_in_trix_editor('internship_offer_description_rich_text', with: 'description')
    click_on "Modifier l'offre"
    wait_form_submitted
    internship_offer = InternshipOffer.find internship_offer_id
    assert internship_offer.type == 'InternshipOffers::WeeklyFramed'

    visit edit_dashboard_internship_offer_path(internship_offer)

    select 'Bac pro', from: 'Filière cible'
    fill_in 'internship_offer_title', with: 'editok'
    find('#internship_offer_description_rich_text', visible: false).set("On fait des startup d'état qui déchirent")
    click_on "Modifier l'offre"
    wait_form_submitted
    internship_offer = InternshipOffer.find internship_offer_id
    assert internship_offer.type == 'InternshipOffers::FreeDate'
    assert_equal 'editok', internship_offer.title
  end

  test 'employer can see which week is choosen by nearby schools on edit' do
    employer = create(:employer)


    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      week_with_school = Week.find_by(number: 10, year: Date.today.year)
      week_without_school = Week.find_by(number: 11, year: Date.today.year)
      create(:school, weeks: [week_with_school])
      internship_offer = create(:weekly_internship_offer, employer: employer, weeks: [week_with_school])

      visit edit_dashboard_internship_offer_path(internship_offer)
      find(".bg-success-20[data-week-id='#{week_with_school.id}']", count: 1)
      find(".bg-dark-70[data-week-id='#{week_without_school.id}']", count: 1)
    end
  end

  test 'can discard internship_offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer),
      create(:free_date_internship_offer, employer: employer)
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit dashboard_internship_offer_path(internship_offer)
      assert_changes -> { internship_offer.reload.discarded_at } do
        page.find('a[data-target="#discard-internship-offer-modal"]').click
        page.find('#discard-internship-offer-modal .btn-primary').click
      end
    end
  end

  test 'can publish/unpublish internship_offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer),
      create(:free_date_internship_offer, employer: employer)
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit dashboard_internship_offer_path(internship_offer)
      assert_changes -> { internship_offer.reload.published_at } do
        page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
        wait_form_submitted
        assert_nil internship_offer.reload.published_at, 'fail to unpublish'

        page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
        wait_form_submitted
        assert_in_delta Time.now.utc.to_i,
                        internship_offer.reload.published_at.utc.to_i,
                        delta = 10
      end
    end
  end

  test 'Employer can change max candidates parameter back and forth' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    assert_equal 1, internship_offer.max_candidates
    sign_in(employer)
    visit dashboard_internship_offers_path(internship_offer: internship_offer)
    page.find("a[data-test-id=\"#{internship_offer.id}\"]").click
    click_link("Modifier")
    find('label[for="internship_type_false"]').click # max_candidates can be set to many now
    within('.form-group-select-max-candidates') do
      fill_in('Nombre de stagiaires maximum par groupe', with: 20)
    end
    click_button('Modifier l\'offre')
    assert_equal 20, internship_offer.reload.max_candidates

    visit dashboard_internship_offers_path(internship_offer: internship_offer)
    page.find("a[data-test-id=\"#{internship_offer.id}\"]").click
    click_link("Modifier")
    find('label[for="internship_type_true"]').click
    click_button('Modifier l\'offre')
    assert_equal 1, internship_offer.reload.max_candidates
  end

  test 'Employer can filter internship_offers from dashboard filters' do
    travel_to(Date.new(2020, 10, 10)) do
      employer = create(:employer)

      week_1 = Week.find_by(year: 2019, number: 50) #2019-20
      week_2 = Week.find_by(year: 2020, number: 2)  #2019-20
      week_3 = Week.find_by(year: 2021, number: 2)  #2020-21

      # 2019-20
      create(:weekly_internship_offer, weeks: [week_1, week_2], employer: employer, title: '2019/2020')

      # 2020-21
      target_offer = create(:weekly_internship_offer, weeks: [week_3], employer: employer, title: '2020/2021')

      # wrong employer
      create(:weekly_internship_offer, weeks: [week_2], title: 'wrong employer')

      # free
      create(:free_date_internship_offer, employer: employer, title: 'free')

      # 2019-20 unpublished
      io = create(:weekly_internship_offer, employer: employer, weeks: [week_1, week_2], title: '2019/2020 unpublished')
      io.update_column(:published_at, nil)
      io.reload

      # 2020-21
      create(:weekly_internship_application, :approved, internship_offer: target_offer)

      sign_in(employer)
      visit dashboard_internship_offers_path

      refute page.has_css?('.school_year')

      click_link('Passées')
      assert page.has_css?('p.internship-item-title.mb-0', count: 2)
      assert_text('2019/2020')
      assert_text('2019/2020 unpublished')

      select('2019/2020')
      assert page.has_css?('p.internship-item-title.mb-0', count: 2)
      assert_text('2019/2020')
      assert_text('2019/2020 unpublished')

      select('2020/2021')
      assert page.has_css?('p.internship-item-title.mb-0', count: 0)

      click_link('Dépubliées')
      assert page.has_css?('p.internship-item-title.mb-0', count: 1)
      assert_text('2019/2020 unpublished')

      select('2019/2020')
      assert page.has_css?('p.internship-item-title.mb-0', count: 1)
      assert_text('2019/2020 unpublished')
      select('2020/2021')
      assert page.has_css?('p.internship-item-title.mb-0', count: 0)
      if ENV['CONVENTION_ENABLED']
        page.find("a[href=\"/dashboard/internship_applications\"]", text: 'Conventions à signer')
        page.find("a[href=\"/dashboard/internship_applications\"] > div.my-auto > span.red-notification-badge", text: '1')
        click_link('Conventions à signer')
        page.find("a[href=\"/dashboard/internship_applications\"] > div.my-auto > span.red-notification-badge", text: '1')
      end
    end
  end

end
