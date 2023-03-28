require 'application_system_test_case'

module Dashboard
  class InternshipAgreementTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'employer reads internship agreement list and read his own agreements with student having a school with a school manager' do
      employer =  create(:employer)
      employer_2 =  create(:employer)

      student = create(:student, school: create(:school))
      refute student.school.school_manager.present?

      internship_offer = create(:internship_offer, employer: employer)
      internship_offer_2 = create(:internship_offer, employer: employer_2)
      internship_application = create(
        :weekly_internship_application,
        internship_offer: internship_offer,
        student: student)
      internship_application_2 = create(:weekly_internship_application, internship_offer: internship_offer_2)
      create(:internship_agreement, aasm_state: :draft, internship_application: internship_application)
      create(:internship_agreement, aasm_state: :draft, internship_application: internship_application_2)

      
      sign_in(employer)
      visit dashboard_internship_agreements_path

      assert all('td[data-head="Statut"]').empty?
    end

    test 'school_manager reads internship agreement list and read his own agreements' do
      school = create(:school, :with_school_manager)
      school_2 = create(:school)
      student = create(:student, school: school)
      student_2 = create(:student, school: school_2)
      internship_offer = create(:internship_offer)
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer, student: student)
      internship_application_2 = create(:weekly_internship_application, internship_offer: internship_offer, student: student_2)
      create(:internship_agreement, aasm_state: :draft, internship_application: internship_application)
      create(:internship_agreement, aasm_state: :draft, internship_application: internship_application_2)
      sign_in(school.school_manager)
      visit dashboard_internship_agreements_path

      within('td[data-head="Statut"]') do
        assert_equal 1, all('div.actions').count
      end
    end

    test 'employer reads internship agreement table with correct indications - draft' do
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'À remplir par les deux parties.')
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention').click
      fill_in "Fonction du représentant de l'entreprise", with: 'CEO'
      fill_in "Email du tuteur", with: 'tuteur@free.fr'
      select('08:00', from:'internship_agreement_weekly_hours_start')
      select('16:00', from:'internship_agreement_weekly_hours_end')
      fill_in('Pause déjeuner', with: "un repas à la cantine d'entreprise")
      click_button('Envoyer la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: "Envoyer la convention")
    end

    test 'employer reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Vérifier ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Vérifier ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est prête. Imprimez-la et renvoyez-la signée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :employer, user_id: internship_agreement.employer.id)
      sign_in(internship_agreement.employer.reload)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature du chef d’établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'employer reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :school_manager, user_id: internship_agreement.school_manager.id)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Le chef d'établissement a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Signée par toutes les parties.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end

    # =================== School Manager ===================

    test 'school_manager reads internship agreement table with correct indications - draft' do
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      find('a.button-component-cta-button', text: 'Remplir ma convention').click
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie par l'offreur, mais vous ne l'avez pas renseignée.")
      end
      text = "Le chef d'établissement a été nommé apte à signer les conventions par le conseil d'administration de l'établissement en date du"
      fill_in text, with: "12/02/2015"
      click_button('Valider la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: "Valider la convention")
      click_button('Je valide la convention')
      find("span#alert-text", text: "La convention est validée, le fichier pdf de la convention est maintenant disponible.")
    end

    test 'school_manager reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais pas validée.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'school_manager reads internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est prête.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :employer, user_id: internship_agreement.employer.id)
      sign_in(internship_agreement.school_manager.reload)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "L'employeur a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :school_manager, user_id: internship_agreement.school_manager.id)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature de l’employeur.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Signée par toutes les parties.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end

    # =================== Statistician ===================

    test 'statistician without rights attempt to reach internship agreement table fails' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: false))
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      find('span#alert-text', text: "Vous n'êtes pas autorisé à effectuer cette action.")
    end

    test 'statistician reads internship agreement table with correct indications - draft' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :draft, internship_application: internship_application)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'À remplir par les deux parties.')
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'statistician reads internship agreement table with correct indications - status: started_by_employer' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer, internship_application: internship_application)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'statistician reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer, internship_application: internship_application)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Vérifier ma convention')
    end

    test 'statistician reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager, internship_application: internship_application)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Vérifier ma convention')
    end

    test 'statistician reads internship agreement table with correct indications - status: validated' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :validated, internship_application: internship_application)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est prête. Imprimez-la et renvoyez-la signée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'statistician reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      employer = internship_offer.employer
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started, internship_application: internship_application)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :employer, user_id: internship_agreement.employer.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature du chef d’établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'statistician reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      employer = internship_offer.employer
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started, internship_application: internship_application)
      school_manager = internship_agreement.internship_application.student.school.school_manager
      create(:signature, internship_agreement: internship_agreement, signatory_role: :school_manager, user_id: school_manager.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Le chef d'établissement a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'statistician reads internship agreement table with correct indications - status: signed_by_all' do
      internship_offer = create(:internship_offer, employer: create(:statistician, agreement_signatorable: true))
      employer = internship_offer.employer
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all, internship_application: internship_application)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Signée par toutes les parties.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end
  end
end