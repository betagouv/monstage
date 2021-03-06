require 'application_system_test_case'

class ManageComplteOfferFillingTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include OrganisationFormFiller
  include InternshipOfferInfoFormFiller
  include TutorFormFiller

  def wait_form_submitted
    find('.alert-sticky')
  end

  test 'can create navigate back and forth while creating an offer' do
    2.times { create(:school) }
    employer              = create(:employer)
    group                 = create(:group, name: 'hello', is_public: true)
    sector                = create(:sector)
    # organisation          = create(:organisation, employer: employer)
    # internship_offer_info = create(:weekly_internship_offer_info,  employer: employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    travel_to(Date.new(2019, 3, 1)) do
      sign_in(employer)
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      # organisation = Organisation.all.last
      fill_in_organisation_form(is_public: true, group: group)
      click_on "Suivant"
      click_link "Précédent"
      find('legend', text: 'Information sur l\'entreprise')
      click_on "Suivant"
      find('legend', text: 'Offre de stage')
      fill_in_internship_offer_info_form(school_track: :troisieme_generale,
                                         sector: sector,
                                         weeks: available_weeks)

      click_on "Suivant"
      find('legend', text: 'Informations complémentaires')
      click_on "Précédent"
      find('legend', text: 'Offre de stage')
      click_on "Précédent"
      find('legend', text: 'Information sur l\'entreprise')
      click_on "Suivant"
      find('legend', text: 'Offre de stage')
      click_on "Suivant"
      find('legend', text: 'Informations complémentaires')
      fill_in_tutor_form
      click_on "Publier l'offre !"
      wait_form_submitted
    end
  end
end