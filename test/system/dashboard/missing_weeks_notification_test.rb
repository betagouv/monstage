require 'application_system_test_case'


class MissingWeeksNotificationTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  # include ActiveJob::TestHelper

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end
  def refute_presence_of(internship_offer:)
    refute_selector "a[data-test-id='#{internship_offer.id}']"
  end

  test 'student troisieme try to apply to an offer while school manager has not open any internship week' do
    internship_offer = create(:weekly_internship_offer)
    school = create(:school, :with_school_manager, weeks: [])
    school_manager = school.school_manager
    class_room = create(:class_room, school: school)
    student = create(:student, school: school, class_room: class_room)
    message_no_week = "Attention, votre établissement n'a pas encore renseigné ses dates de stage."
    student_message = "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
    explanation = "Attention, vérifiez bien que les dates de stage proposées dans l'annonce correspondent " \
                  "à vos dates de stage. Votre chef d'établissement n'a en effet pas renseigné " \
                  "les semaines de stage de votre établissement." \
                  
    school_message = "Etablissement mis à jour avec succès"

    InternshipOffer.stub :nearby, InternshipOffer.all do
      sign_in(student)
      visit internship_offers_path
      click_link("Voir l'annonce")
      click_on 'Postuler'
      find ".fr-label", text: "Quelle semaine ?"
      find "p.test-missing-school-weeks", text: explanation
      page.find "input[name='commit']", visible: true
      sign_out(student)

      # Back to interfaces
      sign_in(school_manager)
      visit edit_dashboard_school_path(school)
      all(".fr-checkbox-group.fr-checkbox-group--sm label").first.click
      find('input[type="submit"]').click
      find "#alert-text", text: school_message
      sign_out(school_manager)

      sign_in(student)
      visit internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
      page.has_no_content?(message_no_week)
      click_link("Voir l'annonce")
      click_on 'Postuler'
      page.has_no_content?(explanation)
    end
  end

  test 'troisieme segpa student try to apply to an offer while school manager has not open any internship week' do
    internship_offer = create(:troisieme_segpa_internship_offer)
    school = create(:school, :with_school_manager, weeks: [])
    class_room = create(:class_room, :troisieme_segpa, school: school)
    student = create(:student, school: school, class_room: class_room)
    student_message = "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
    student_wish_message = "Je souhaite une semaine de stage"

    InternshipOffer.stub :nearby, InternshipOffer.all do
      sign_in(student)
      visit internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
      click_link("Voir l'annonce")
      click_on 'Postuler'
      page.has_no_content? student_wish_message
      page.has_no_content? student_message

      visit internship_offers_path
      click_link("Voir l'annonce")
      click_on 'Postuler'
      find ".fr-label", text: "Pourquoi ce stage me motive"
      page.find "input[name='commit']"
      sign_out(student)
    end
  end
end
