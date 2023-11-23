require 'application_system_test_case'


class MissingWeeksNotificationTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  # include ActiveJob::TestHelper

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end
  # def refute_presence_of(internship_offer:)
  #   refute_selector "a[data-test-id='#{internship_offer.id}']"
  # end

  test 'student troisieme try to apply to an offer while school manager has not open any internship week' do
    travel_to(Date.new(2019, 3, 1)) do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, :with_school_manager, weeks: [])
      school_manager = school.school_manager
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      message_no_week = "Attention, votre établissement n'a pas encore renseigné ses dates de stage."
      explanation = "Attention, vérifiez bien que les dates de stage proposées dans l'annonce correspondent " \
                    "à vos dates de stage. Votre chef d'établissement n'a en effet pas renseigné " \
                    "les semaines de stage de votre établissement." \

      school_message = "Etablissement mis à jour avec succès"


      InternshipOffer.stub :nearby, InternshipOffer.all do
        sign_in(student)
        visit internship_offer_path(internship_offer)
        first(:link, 'Postuler').click
        find "label[for='internship_application_internship_offer_week_id']", text: "Quelle semaine ?"
        find "p.test-missing-school-weeks", text: explanation
        page.find "input[name='commit']", visible: true
        sign_out(student)

        # Back to interfaces /!\ works alone
        sign_in(school_manager)
        visit edit_dashboard_school_path(school)
        find("label", text: "Du 21 au 25 janvier 2019").click
        click_button('Enregistrer les modifications')
        find "#alert-text", text: school_message
        sign_out(school_manager)

        sign_in(student)
        visit internship_offers_path
        page.has_no_content?(message_no_week)
      end
    end
  end
end
