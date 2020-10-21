# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  def wait_form_submitted
    find('.alert-sticky')
  end

  def fill_in_form
    fill_in 'Nom du tuteur/trice', with: 'Brice Durand'
    fill_in 'Adresse électronique / Email', with: 'le@brice.durand'
    fill_in 'Numéro de téléphone', with: '0639693969'
  end

  test 'can create InternshipOffer' do
    employer = create(:employer)
    sign_in(employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info,  employer: employer)
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        fill_in_form
        click_on "Publier l'offre !"
        wait_form_submitted
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
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

  # test 'can edit school_track of an internship offer back and forth' do
  #   employer = create(:employer)
  #   internship_offer = create(:free_date_internship_offer, employer: employer)
  #   sign_in(employer)

  #   visit edit_dashboard_internship_offer_path(internship_offer)
  #   select '3e générale'
  #   click_on "Enregistrer et publier l'offre"

  #   visit edit_dashboard_internship_offer_path(internship_offer)
  #   select 'Bac pro'
  #   fill_in 'internship_offer_title', with: 'editok'
  #   find('#internship_offer_description_rich_text', visible: false).set("On fait des startup d'état qui déchirent")
  #   click_on "Enregistrer et publier l'offre"
  #   wait_form_submitted
  #   assert_equal 'editok', internship_offer.reload.title
  # end

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

  test 'Employer can filter internship_offers from dashboard filters' do
    employer = create(:employer)

    week_1 = Week.find_by(year: 2019, number: 50) #2019-20
    week_2 = Week.find_by(year: 2020, number: 2)  #2019-20
    week_3 = Week.find_by(year: 2021, number: 2)  #2020-21

    # 2019-20
    create(:weekly_internship_offer, weeks: [week_1, week_2], employer: employer, title: '2019/2020')

    # 2020-21
    create(:weekly_internship_offer, weeks: [week_3], employer: employer, title: '2020/2021')

    # wrong employer
    create(:weekly_internship_offer, weeks: [week_2], title: 'wrong employer')

    # free
    create(:free_date_internship_offer, employer: employer, title: 'free')

    # 2019-20 unpublished
    io = create(:weekly_internship_offer, employer: employer, weeks: [week_1, week_2], title: '2019/2020 unpublished')
    io.update_column(:published_at, nil)
    io.reload

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
  end
end
