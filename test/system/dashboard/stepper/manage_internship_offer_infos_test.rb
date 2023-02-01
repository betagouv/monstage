# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOfferInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOfferInfoFormFiller
  include StubsForApiGouvRequests

  setup do
    stub_gouv_api_requests
  end

  # Create a new internship offer info
  test 'can create InternshipOfferInfos::WeeklyFramed' do
    sector = create(:sector)
    employer = create(:employer)
    school_name = 'Abd El Kader'
    organisation = create(:organisation, employer: employer)
    school = create(:school, city: 'Paris', zipcode: 75012, name: school_name)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOfferInfos::WeeklyFramed.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_internship_offer_info_form(sector: sector,
                                           weeks: available_weeks)
        fill_in_address
        page.assert_no_selector('span.number', text: '1')
        find('span.number', text: '2')
        find('span.number', text: '3')
        find('.test-school-reserved').click
        fill_in('Ville ou nom de l\'établissement pour lequel le stage est reservé', with: 'Pari')
        all('.autocomplete-school-results .list-group-item-action').first.click
        select(school_name, from: 'Collège')
        click_on "Suivant"
        find('label', text: 'Nom du tuteur/trice')
        assert InternshipOfferInfos::WeeklyFramed.last.school.id,
               School.find_by(name: school_name).id
      end
      ioi = InternshipOfferInfos::WeeklyFramed.last
      assert_equal school, ioi.school
      assert_equal sector, ioi.sector
      assert_equal 1, ioi.max_candidates
      assert_equal 1, ioi.max_students_per_group
      assert_equal organisation.employer_name, ioi.employer_name
      assert_equal "false", ioi.manual_enter
      assert_equal "12 Rue Origet", ioi.street
      assert_equal "37000", ioi.zipcode
      assert_equal "Tours", ioi.city
      assert_equal 0.68909, ioi.coordinates.longitude
      assert_equal 47.386913, ioi.coordinates.latitude
    end
  end

  test 'employer can see which week is chosen by nearby schools in stepper' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    week_with_school = Week.find_by(number: 10, year: 2019)
    create(:school, weeks: [week_with_school])
    week_without_school = Week.find_by(number: 11, year: 2019)

    sign_in(employer)

    travel_to(Date.new(2019, 3, 1)) do
      visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      find('label[for="all_year_long"]').click
      find(".bg-success-20[data-week-id='#{week_with_school.id}']")
      find(".bg-dark-70[data-week-id='#{week_without_school.id}']")
    end
  end

  test 'create internship offer info fails gracefuly' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      fill_in_internship_offer_info_form(sector: sector,
                                         weeks: available_weeks)
      fill_in_address
      as = 'a' * 151
      fill_in 'internship_offer_info_title', with: as
      click_on "Suivant"
      find('#error_explanation')
    end
  end

  # Edit

  test 'employer can update a school she formerly associated with an offer' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    new_school_name = 'Collège Abd El Kader'
    create(:school, name: new_school_name, city: 'Paris', zipcode: '75012')
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    internship_offer_info = create(:weekly_internship_offer_info,
                                    employer: employer,
                                    weeks: available_weeks,
                                    school: create(:school))
    tutor = create(:tutor, employer: employer)
    internship_offer = create(:weekly_internship_offer,
      organisation: organisation,
      internship_offer_info: internship_offer_info,
      tutor: tutor,
      school: internship_offer_info.school,
      employer: employer)
    assert internship_offer.coordinates.present?
    assert internship_offer_info.coordinates.present?
    travel_to(Date.new(2019, 3, 1)) do
      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('button#tabpanel-internship').click
      within('.autocomplete-school-container') do
        find('button[aria-label="Réinitialiser la recherche"]').click
        fill_in('Ville', with: 'Pari')
        find('li#downshift-0-item-0 span.fr-badge.fr-badge--sm.fr-badge--success.fr-badge--no-icon.fr-ml-1w', text: '2 ÉTABLISSEMENTS').click
        find('select#internship_offer_info_school_id').find(:xpath, 'option[2]').select_option
      end
      find('label', text: 'Toute l\'année scolaire 2022-2023').click
      find('input[type="submit"]').click
      assert_equal new_school_name, internship_offer.internship_offer_info.reload.school.name
      assert_equal new_school_name, internship_offer.reload.school.name
    end
  end

  test 'employer can update weeks in her offer' do
    employer        = create(:employer)
    sector          = create(:sector)
    available_weeks = [Week.find_by(number: 10, year: 2023), Week.find_by(number: 11, year: 2023)]
    available_week_ids = available_weeks.map(&:id)
    organisation    = create(:organisation, employer: employer)
    tutor           = create(:tutor)
    internship_offer_info = create(:weekly_internship_offer_info,
                                    employer: employer,
                                    weeks: available_weeks,

                                  )
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              internship_offer_info: internship_offer_info,
                              tutor: tutor,
                              school: internship_offer_info.school,
                              weeks: available_weeks,
                              employer: employer)
    assert_equal 2, internship_offer.weeks.count
    assert_equal 2, internship_offer.internship_offer_info.weeks.count
    weeks = [Week.find_by(number: 12, year: 2023),
             Week.find_by(number: 13, year: 2023),
             Week.find_by(number: 14, year: 2023)]
    week_ids = weeks.map(&:id)
    travel_to(Date.new(2023, 2, 1)) do
      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('button#tabpanel-internship').click
      fill_in_internship_offer_info_form( weeks: weeks, sector: sector)
      find('input[type="submit"]').click
      find('div.alert.alert-success', text: 'Les modifications sont enregistrées')
      assert_equal 5, internship_offer.reload.weeks.count
      assert_equal 5, internship_offer.internship_offer_info.reload.weeks.count
      (week_ids + available_week_ids).each do |week_id|
        within("#week-container-weeks") do
          # visible false due to DSFR checkbox
          find("input#internship_offer_info_week_ids_#{week_id}_checkbox", visible: false)
          assert find("input#internship_offer_info_week_ids_#{week_id}_checkbox", visible: false).checked?
        end
        within("#week-container-weeks") do
          refute find("input#internship_offer_info_week_ids_#{week_ids.last + 1}_checkbox", visible: false).checked?
        end
      end
    end
  end

  test 'employer can update internship address' do
    employer        = create(:employer)
    sector          = create(:sector)
    available_weeks = [Week.find_by(number: 10, year: 2023), Week.find_by(number: 11, year: 2023)]
    organisation    = create(:organisation, employer: employer)
    tutor           = create(:tutor)
    internship_offer_info = create(:weekly_internship_offer_info,
                                    employer: employer,
                                    weeks: available_weeks)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              internship_offer_info: internship_offer_info,
                              tutor: tutor,
                              school: internship_offer_info.school,
                              weeks: available_weeks,
                              employer: employer)
    assert_equal "1 rue du poulet", internship_offer.street
    assert_equal "1 rue du poulet", internship_offer_info.street
    travel_to(Date.new(2023, 2, 1)) do
      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('button#tabpanel-internship').click
      within('.container-downshift') do
        find('a', text: '... ou faire une recherche').click
      end
      fill_in_address
      find('input[type="submit"]').click
      find('div.alert.alert-success', text: 'Les modifications sont enregistrées')
      assert_equal "12 Rue Origet", internship_offer_info.reload.street
      assert_equal "12 Rue Origet", internship_offer.reload.street
    end
  end

  test 'employer can update internship schedule in her offer' do
    employer        = create(:employer)
    sector          = create(:sector)
    available_weeks = [Week.find_by(number: 10, year: 2023), Week.find_by(number: 11, year: 2023)]
    organisation    = create(:organisation, employer: employer)
    tutor           = create(:tutor)
    internship_offer_info = create(:weekly_internship_offer_info,
                                    employer: employer,
                                    weeks: available_weeks)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              internship_offer_info: internship_offer_info,
                              tutor: tutor,
                              school: internship_offer_info.school,
                              weeks: available_weeks,
                              employer: employer)
    travel_to(Date.new(2023, 2, 1)) do
      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('button#tabpanel-internship').click
      find('label', text: 'Toute l\'année scolaire 2022-2023').click

      # Default is weekly planning
      find('label[for="same_daily_planning"]').click
      execute_script("document.getElementById('daily-planning').style.display='block';")
      execute_script("document.getElementById('weekly-planning').style.display='none';")
      # now on a daily basis
      within('#daily-planning') do
        find('#lundi-label.fr-label', text: 'Lundi')
        find('#samedi-label.fr-label', text: 'Samedi')
        find('#internship_offer_info_new_daily_hours_lundi_start').select('8:00')
        find('#internship_offer_info_new_daily_hours_lundi_end').select('15:30')
        find('#internship_offer_info_new_daily_hours_mardi_start').select('8:00')
        find('#internship_offer_info_new_daily_hours_mardi_end').select('15:30')
        find('#internship_offer_info_new_daily_hours_mercredi_start').select('9:30')
        find('#internship_offer_info_new_daily_hours_mercredi_end').select('15:30')
        find('#internship_offer_info_new_daily_hours_jeudi_start').select('8:30')
        find('#internship_offer_info_new_daily_hours_jeudi_end').select('15:30')
        find('#internship_offer_info_new_daily_hours_vendredi_start').select('8:30')
        find('#internship_offer_info_new_daily_hours_vendredi_end').select('14:30')
        find('#internship_offer_info_new_daily_hours_samedi_start').select('--')
        find('#internship_offer_info_new_daily_hours_samedi_end').select('--')
        fill_in('internship_offer_info_daily_lunch_break[lundi]', with: 'on verra bien lundi')
        fill_in('internship_offer_info_daily_lunch_break[mardi]', with: 'on verra bien mardi')
        fill_in('internship_offer_info_daily_lunch_break[mercredi]', with: 'on verra bien mercredi')
        fill_in('internship_offer_info_daily_lunch_break[jeudi]', with: 'on verra bien jeudi')
        fill_in('internship_offer_info_daily_lunch_break[vendredi]', with: 'on verra bien vendredi')
        fill_in('internship_offer_info_daily_lunch_break[samedi]', with: '')
      end
      find('input[type="submit"]').click
      find('div.alert.alert-success', text: 'Les modifications sont enregistrées')
      internship_offer_info.reload
      assert_equal ["08:00", "15:30"], internship_offer_info.new_daily_hours["lundi"]
      assert_equal ["08:00", "15:30"], internship_offer_info.new_daily_hours["mardi"]
      assert_equal ["09:30", "15:30"], internship_offer_info.new_daily_hours["mercredi"]
      assert_equal ["08:30", "15:30"], internship_offer_info.new_daily_hours["jeudi"]
      assert_equal ["08:30", "14:30"], internship_offer_info.new_daily_hours["vendredi"]
      assert_equal [], internship_offer_info.daily_hours
      assert_equal 'on verra bien lundi', internship_offer_info.daily_lunch_break["lundi"]
      assert_equal 'on verra bien mardi', internship_offer_info.daily_lunch_break["mardi"]
      assert_equal 'on verra bien mercredi', internship_offer_info.daily_lunch_break["mercredi"]
      assert_equal 'on verra bien jeudi', internship_offer_info.daily_lunch_break["jeudi"]
      assert_equal 'on verra bien vendredi', internship_offer_info.daily_lunch_break["vendredi"]
      assert_equal '', internship_offer_info.daily_lunch_break["samedi"]
      assert_equal ["",""], internship_offer_info.weekly_hours

      internship_offer.reload
      assert_equal ["08:00", "15:30"], internship_offer.new_daily_hours["lundi"]
      assert_equal ["08:00", "15:30"], internship_offer.new_daily_hours["mardi"]
      assert_equal ["09:30", "15:30"], internship_offer.new_daily_hours["mercredi"]
      assert_equal ["08:30", "15:30"], internship_offer.new_daily_hours["jeudi"]
      assert_equal ["08:30", "14:30"], internship_offer.new_daily_hours["vendredi"]
      assert_equal ["",""], internship_offer.new_daily_hours["samedi"]
      assert_equal 'on verra bien lundi', internship_offer.daily_lunch_break["lundi"]
      assert_equal 'on verra bien mardi', internship_offer.daily_lunch_break["mardi"]
      assert_equal 'on verra bien mercredi', internship_offer.daily_lunch_break["mercredi"]
      assert_equal 'on verra bien jeudi', internship_offer.daily_lunch_break["jeudi"]
      assert_equal 'on verra bien vendredi', internship_offer.daily_lunch_break["vendredi"]
      assert_equal '', internship_offer.daily_lunch_break["samedi"]
      assert_equal ["",""], internship_offer.weekly_hours

      # Staying on the same page
      find('label[for="same_daily_planning"]').click
      execute_script("document.getElementById('weekly-planning').style.display='block';")
      execute_script("document.getElementById('daily-planning').style.display='none';")
      # now back on a weekly basis
      find('#internship_offer_info_weekly_hours_start').select("08:00")
      find('#internship_offer_info_weekly_hours_end').select("14:30")
      fill_in('Pause déjeuner', with: 'on verra, peut-être ira-t-on au restaurant  :-)')
      find('input[type="submit"]').click
      find('div.alert.alert-success', text: 'Les modifications sont enregistrées')

      internship_offer_info.reload
      assert_equal ["08:00", "14:30"], internship_offer_info.weekly_hours
      assert_equal [], internship_offer_info.daily_hours
      assert_equal 'on verra, peut-être ira-t-on au restaurant  :-)', internship_offer_info.weekly_lunch_break
      internship_offer.reload
      assert_equal ["08:00", "14:30"], internship_offer.weekly_hours
      assert_equal [], internship_offer.daily_hours
      assert_equal 'on verra, peut-être ira-t-on au restaurant  :-)', internship_offer.weekly_lunch_break
    end
  end

  test 'fails gracefully when employer maximize max_candidates and forgets to increate weeks number accordingly' do
    employer        = create(:employer)
    sector          = create(:sector)
    available_weeks = [Week.find_by(number: 10, year: 2023), Week.find_by(number: 11, year: 2023)]
    organisation    = create(:organisation, employer: employer)
    tutor           = create(:tutor)
    internship_offer_info = create(:weekly_internship_offer_info,
                                    employer: employer,
                                    weeks: available_weeks)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              internship_offer_info: internship_offer_info,
                              tutor: tutor,
                              school: internship_offer_info.school,
                              weeks: available_weeks,
                              employer: employer)
    travel_to(Date.new(2023, 2, 1)) do
      sign_in(employer)
      visit edit_dashboard_internship_offer_path(internship_offer)
      find('button#tabpanel-internship').click
      label = "Nombre total d'élèves que vous souhaitez accueillir sur l'année scolaire"
      fill_in(label, with: '1000')

      assert_equal 2, internship_offer_info.weeks.count
      assert_equal 1, internship_offer_info.max_students_per_group
      # upper context triggers an error
      find('input[type="submit"]').click
      find('#error_explanation.alert.alert-danger')
      within('#error_explanation.alert.alert-danger') do
        find('p', text: 'Une erreur à corriger')
      end
      text = "doit être inférieur ou égal à 200"
      assert_equal 2, all('li label[for="internship_offer_info_max_candidates"]').count
      assert_equal text, all('li label[for="internship_offer_info_max_candidates"]').first.text
      text = "Le nombre maximal d'élèves est trop important par rapport au nombre de semaines de stage " \
             "choisi. Ajoutez des semaines de stage ou augmentez la taille des groupes ou diminuez " \
             "le nombre de stagiaires prévus."
      assert_equal text, all('li label[for="internship_offer_info_max_candidates"]')[1].text
      assert_equal 1, internship_offer_info.reload.max_candidates
      assert_equal 1, internship_offer.reload.max_candidates
    end
  end
end
