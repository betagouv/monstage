require 'application_system_test_case'
module Dashboard::InternshipOffers
  class InternshipApplicationsUpdateTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test 'employer can set to read status an internship_application' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(employer)
      visit dashboard_candidatures_path
      click_link 'Répondre'
      click_on 'retour'
      assert internship_application.reload.read_by_employer?
      find("h2.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--warning', text: "LU")
    end

    test 'employer can set to examine status an internship_application' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(employer)
      visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
      click_on 'Etudier'
      text = find("#internship_application_examined_message").text
      find("#internship_application_examined_message").click.set("#{text} (test)")
      click_button 'Confirmer'
      assert internship_application.reload.examined?
      find("h2.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--info', text: "à l'étude".upcase)
      find('span#alert-text', text: "Candidature mise à jour.")
    end
    
    test 'employer can reject an internship_application' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(employer)
      visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
      click_on 'Refuser'
      find("#internship_application_rejected_message").click.set("(test ata test)")
      click_button 'Confirmer'
      assert internship_application.reload.rejected?
      find("h2.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--error', text: "REFUSÉ")
      find('span#alert-text', text: "Candidature refusée.")
      find('button#tabpanel-received[aria-controls="tabpanel-received-panel"]',  text: 'Reçues').click
      find('td.text-center[colspan="5"]', text: "Aucune candidature reçue")
    end

    test 'employer can accept an internship_application' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(employer)
      visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
      click_on 'Accepter'
      click_button 'Confirmer'
      assert internship_application.reload.validated_by_employer?
      find("h2.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--info', text: "en attente de réponse".upcase)

      find('span#alert-text', text: "Candidature mise à jour avec succès.")
      find('button#tabpanel-received[aria-controls="tabpanel-received-panel"]',  text: 'Reçues').click
      find('td.text-center[colspan="5"]', text: "Aucune candidature reçue")
    end

    test 'employer can unpublish an internship_offer from index page' do
      employer, internship_offer = create_employer_and_offer
      assert internship_offer.published?
      assert_equal 'published', internship_offer.aasm_state
      refute_equal nil, internship_offer.published_at


      sign_in(employer)
      visit dashboard_internship_offers_path
      find("td #toggle_status_internship_offers_weekly_framed_#{internship_offer.id}")
      find("td #toggle_status_internship_offers_weekly_framed_#{internship_offer.id}").click
      find("td #toggle_status_internship_offers_weekly_framed_#{internship_offer.id} .label", text: 'Masqué')
      refute internship_offer.reload.published?
    end

    test 'employer can publish an internship_offer from index page' do
      employer, internship_offer = create_employer_and_offer
      internship_offer.unpublish!
      refute internship_offer.published?
      assert_equal 'unpublished', internship_offer.aasm_state
      assert_nil internship_offer.published_at


      sign_in(employer)
      visit dashboard_internship_offers_path
      find("td #toggle_status_internship_offers_weekly_framed_#{internship_offer.id}")
      find("td #toggle_status_internship_offers_weekly_framed_#{internship_offer.id}").click
      find("td #toggle_status_internship_offers_weekly_framed_#{internship_offer.id} .label", text: 'Publié')
      assert internship_offer.reload.published?
    end

    test 'employer can transfer an internship_application' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(employer)
      visit dashboard_candidatures_path
      click_link 'Répondre'
      click_on 'Transférer'
      fill_in 'Adresse email', with: 'test@free.fr'
      text_area = first(:css, 'textarea.fr-input').native
      text_area.send_keys('Test')
      click_on 'Envoyer'
      find('h2', text: 'Les candidatures')
      assert_match /La candidature a été transmise avec succès/, find('div.alert.alert-success').text
      click_on 'Répondre'
      find('button[data-toggle="modal"][data-fr-js-modal-button="true"]', text: 'Accepter')
      find('button[data-toggle="modal"][data-fr-js-modal-button="true"]', text: 'Refuser')
    end

    test 'employer cannot transfer an internship_application with a faulty email' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(employer)
      visit dashboard_candidatures_path
      click_link 'Répondre'
      click_on 'Transférer'
      fill_in 'Adresse email', with: '@test@free.fr'
      text_area = first(:css, 'textarea.fr-input').native
      text_area.send_keys('Test')
      click_on 'Envoyer'
      assert_match /Transférer une candidature/, find('h1').text
    end
  end
end
