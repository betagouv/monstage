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

  test 'Employer can edit internship offer' do
    travel_to(Date.new(2019, 3, 1)) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)

      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('input[name="internship_offer[employer_name]"]').fill_in(with: 'NewCompany')

      click_on "Modifier l'offre"

      wait_form_submitted
      assert /NewCompany/.match?(internship_offer.reload.employer_name)
    end
  end


  test 'Employer can see which week is choosen by nearby schools on edit' do
    employer = create(:employer)
    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      week_with_school = Week.find_by(number: 10, year: Date.today.year)
      week_without_school = Week.find_by(number: 11, year: Date.today.year)
      create(:school, weeks: [week_with_school])
      internship_offer = create(:weekly_internship_offer, employer: employer, weeks: [week_with_school])

      visit edit_dashboard_internship_offer_path(internship_offer)
      find(".bg-success-20[data-week-id='#{week_with_school.id}']")
      find(".bg-dark-70[data-week-id='#{week_without_school.id}']")
    end
  end

  test 'Employer can discard internship_offer' do
    # employer = create(:employer)
    # internship_offers = [
    #   create(:weekly_internship_offer, employer: employer),
    #   create(:free_date_internship_offer, employer: employer)
    # ]
    # sign_in(employer)

    # internship_offers.each do |internship_offer|
    #   visit dashboard_internship_offer_path(internship_offer)
    #   assert_changes -> { internship_offer.reload.discarded_at } do
    #     page.find('a[data-target="#discard-internship-offer-modal"]').click
    #     page.find('#discard-internship-offer-modal .btn-primary').click
    #   end
    # end
  end

  test 'Employer can publish/unpublish internship_offer' do
    internship_offer = create(:weekly_internship_offer)
    sign_in(internship_offer.employer)

    visit dashboard_internship_offer_path(internship_offer)
    assert_changes -> { internship_offer.reload.published_at } do
      page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
      sleep 0.2
      assert_nil internship_offer.reload.published_at, 'fail to unpublish'

      page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
      sleep 0.2
      assert_in_delta Time.now.utc.to_i,
                      internship_offer.reload.published_at.utc.to_i,
                      delta = 10
    end
  end

  test 'Employer can change max candidates parameter back and forth' do
    travel_to(Date.new(2022, 1, 10)) do
      employer = create(:employer)
      weeks = Week.selectable_from_now_until_end_of_school_year.last(4)
      internship_offer = create(:weekly_internship_offer, employer: employer, weeks: weeks)
      assert_equal 1, internship_offer.max_candidates
      sign_in(employer)
      visit dashboard_internship_offers_path(internship_offer: internship_offer)
      page.find("a[data-test-id=\"#{internship_offer.id}\"]").click
      
      click_link("Modifier")
      find('label[for="internship_type_false"]').click # max_candidates can be set to many now
      within('.form-group-select-max-candidates') do
        fill_in('Nombre total d\'élèves que vous souhaitez accueillir sur l\'année scolaire', with: 4)
      end
      execute_script("document.getElementById('internship_offer_max_students_per_group').value = '2';")
      click_button('Modifier l\'offre')
      assert_equal 4,
                  internship_offer.reload.max_candidates,
                  'faulty max_candidates'
      assert_equal 2,
                  internship_offer.max_students_per_group,
                  'faulty max_students_per_group'

      visit dashboard_internship_offers_path(internship_offer: internship_offer)
      page.find("a[data-test-id=\"#{internship_offer.id}\"]").click
      click_link("Modifier")
      find('label[for="internship_type_true"]').click # max_candidates is now set to 1
      click_button('Modifier l\'offre')
      assert_equal 4, internship_offer.reload.max_candidates
      assert_equal 1, internship_offer.reload.max_students_per_group
    end
  end

  test 'Employer can renew an old internship offer' do
    employer = create(:employer)
    older_weeks = [Week.of_previous_school_year.first]
    old_internship_offer = create(
      :weekly_internship_offer,
      employer: employer,
      weeks: older_weeks
    )
    sign_in(employer)
    visit dashboard_internship_offers_path(internship_offer: old_internship_offer, filter: 'past')
    page.find("a[data-test-id=\"#{old_internship_offer.id}\"]").click
    find('.test-renew-button').click
    assert_selector('h1', text: "Renouveler l'offre pour l'année en cours")
    click_button("Renouveler l'offre")
    assert_selector(
      "#alert-text",
      text: "Votre offre de stage a été renouvelée pour cette année scolaire."
    )
  end

  test 'Employer can duplicate an internship offer' do
    employer = create(:employer)
    older_weeks = [Week.selectable_from_now_until_end_of_school_year.first]
    current_internship_offer = create(
      :weekly_internship_offer,
      employer: employer,
      weeks: older_weeks
    )
    sign_in(employer)
    visit dashboard_internship_offers_path(internship_offer: current_internship_offer)
    page.find("a[data-test-id=\"#{current_internship_offer.id}\"]").click
    find(".test-duplicate-button").click
    assert_selector('h1', text: "Dupliquer une offre")
    click_button('Dupliquer l\'offre')
    assert_selector(
      "#alert-text",
      text: "L'offre de stage a été dupliquée en tenant " \
            "compte de vos éventuelles modifications."
    )
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

      # 2019-20 unpublished
      io = create(:weekly_internship_offer, employer: employer, weeks: [week_1, week_2], title: '2019/2020 unpublished')
      io.update_column(:published_at, nil)
      io.reload

      # 2020-21
      application = create(:weekly_internship_application, :approved, internship_offer: target_offer)

      sign_in(employer)
      visit dashboard_internship_offers_path

      refute page.has_css?('.school_year')
      click_link('Passées')
      find('.active', text: "Passées (2)")

      select('2019/2020')
      find('.active', text: "Passées (2)")

      select('2020/2021')
      find('.active', text: "Passées (0)")

      click_link('Dépubliées')
      find('.active', text: "Dépubliées (0)")

      select('2019/2020')
      assert page.has_css?('p.internship-item-title.mb-0', count: 1)
      assert_text('2019/2020 unpublished')
      select('2020/2021')
      assert page.has_css?('p.internship-item-title.mb-0', count: 0)
      page.find("a[href=\"/dashboard/internship_agreements\"]", text: 'Mes Conventions de stage')
      page.find("a[href=\"/dashboard/internship_agreements\"] ", text: '1')
      click_link('Conventions de stage')
      page.find("a[href=\"/dashboard/internship_agreements\"] ", text: '1')
    end
  end
end
