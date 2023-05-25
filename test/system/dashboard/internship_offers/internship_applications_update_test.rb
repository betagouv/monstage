require 'application_system_test_case'
module Dashboard::InternshipOffers
  class InternshipApplicationsUpdateTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'employer can set to read status an internship_application' do
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(internship_application.employer)
      visit dashboard_candidatures_path
      click_link 'Répondre'
      click_on 'retour'
      assert internship_application.reload.read_by_employer?
      find("h1.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--warning', text: "LU")
    end

    test 'employer can set to examine status an internship_application' do
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(internship_application.employer)
      visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
      click_on 'Etudier'
      text = find("#internship_application_examined_message").text
      find("#internship_application_examined_message").click.set("#{text} (test)")
      click_button 'Confirmer'
      assert internship_application.reload.examined?
      find("h1.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--info', text: "à l'étude".upcase)
      find('span#alert-text', text: "Candidature mise à jour.")
    end
    
    test 'employer can reject an internship_application' do
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(internship_application.employer)
      visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
      click_on 'Refuser'
      find("#internship_application_rejected_message").click.set("(test ata test)")
      click_button 'Confirmer'
      assert internship_application.reload.rejected?
      find("h1.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--error', text: "REFUSÉ")
      find('span#alert-text', text: "Candidature refusée.")
      find('button#tabpanel-received[aria-controls="tabpanel-received-panel"]',  text: 'Reçues').click
      find('td.text-center[colspan="5"]', text: "Aucune candidature reçue")
    end

    test 'employer can accept an internship_application' do
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
      sign_in(internship_application.employer)
      visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
      click_on 'Accepter'
      click_button 'Confirmer'
      assert internship_application.reload.validated_by_employer?
      find("h1.h4", text: "Les candidatures")
      find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--info', text: "en attente de confirmation élève".upcase)

      find('span#alert-text', text: "Candidature mise à jour avec succès.")
      find('button#tabpanel-received[aria-controls="tabpanel-received-panel"]',  text: 'Reçues').click
      find('td.text-center[colspan="5"]', text: "Aucune candidature reçue")
    end
  end
end
