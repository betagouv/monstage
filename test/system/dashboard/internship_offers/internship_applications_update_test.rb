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

    test 'employer cannot validate an internship_application twice for different students' do
      travel_to Date.new(2020, 1, 1) do
        weeks = [Week.find_by(number: 3, year: 2020)]
        school = create(:school, :with_school_manager, weeks: weeks)
        employer, internship_offer = create_employer_and_offer
        internship_offer.update(weeks: weeks)
        assert_equal 1, school.school_internship_weeks.count
        student = create(:student, school: school)
        other_student = create(:student, school: school)
        internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer, student: student)
        sign_in(employer)

        visit dashboard_internship_offer_internship_application_path(internship_offer, internship_application)
        click_on 'Accepter'
        click_button 'Confirmer'
        assert internship_application.reload.validated_by_employer?
        find("h2.h4", text: "Les candidatures")
        find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--info', text: "en attente de réponse".upcase)
        sign_out(employer)

        sign_in(other_student)
        visit internship_offers_path
        click_on internship_offer.title
        first(:link, 'Postuler').click
        select('Semaine du 13 janvier au 19 janvier')
        fill_in 'Numéro de portable élève ou parent',	with: "0600060606"
        click_on 'Valider'
        assert_equal 2, InternshipApplication.count
        other_internship_application = InternshipApplication.last
        sign_out(other_student)

        sign_in(employer)
        visit dashboard_internship_offer_internship_application_path(internship_offer, other_internship_application)
        assert_select('button', text: 'Accepter', count: 0)
      end
    end

    test "other employer can see rejection from student confirmation to another employer's internship_offer" do
      travel_to Date.new(2020, 1, 1) do
        weeks = [Week.find_by(number: 3, year: 2020)]
        school = create(:school, :with_school_manager, weeks: weeks)
        employer_1, internship_offer_1 = create_employer_and_offer
        employer_2, internship_offer_2 = create_employer_and_offer
        student = create(:student, school: school)
        internship_application_1 = create(:weekly_internship_application, :submitted, internship_offer: internship_offer_1, student: student)
        internship_application_2 = create(:weekly_internship_application, :submitted, internship_offer: internship_offer_2, student: student)

        sign_in(employer_2)
        visit dashboard_internship_offer_internship_application_path(internship_offer_2, internship_application_2)
        click_on 'Accepter'
        click_button 'Confirmer'
        assert internship_application_2.reload.validated_by_employer?
        find("h2.h4", text: "Les candidatures")
        find('p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--info', text: "en attente de réponse".upcase)

        # in the meanwhile student approves the second internship_application
        internship_application_2.approve!

        sign_out(employer_2)

        assert_equal %w[canceled_by_student_confirmation approved], InternshipApplication.all.pluck(:aasm_state).sort.reverse

        sign_in(employer_1)
        visit dashboard_candidatures_path
        click_button "Refusées"
        find "p.fr-mt-1w.fr-badge.fr-badge--sm.fr-badge--purple-glycine.fr-badge--no-icon", text: "annulée".upcase
      end
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
