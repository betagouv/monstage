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
    explanation = "Vous ne pouvez postuler à aucun stage, car votre chef"  \
                  " d'établissement n'a pas renseigné les semaines" \
                  " de stage de l'établissement"
    school_message = "Etablissement mis à jour avec succès"

    InternshipOffer.stub :nearby, InternshipOffer.all do
      sign_in(student)

      visit internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
      find "#alert-text", text: message_no_week
      click_link("Voir l'annonce")
      find("a[href='#internship-application-form']").click
      click_link("Je souhaite une semaine de stage")
      find "#alert-text", text: student_message

      visit internship_offers_path
      click_link("Voir l'annonce")
      find("a[href='#internship-application-form']").click
      find ".label", text: "Quelle semaine ?"
      find "p.test-missing-school-weeks", text: explanation
      page.find "input[name='commit'][disabled]", visible: true
      sign_out(student)

      # Cron would find out and mail a notification
      cronjob_instance = Triggers::SchoolMissingWeeksReminder.new
      fake_notify_response = Minitest::Mock.new
      fake_notify_response.expect :call, true, [school]

      cronjob_instance.stub :notify, fake_notify_response do
        cronjob_instance.enqueue_all
      end
      fake_notify_response.verify

      # Back to interfaces
      sign_in(school_manager)

      visit edit_dashboard_school_path(school)
      all(".custom-control.custom-checkbox label").first.click
      find('input[type="submit"]').click
      find "#alert-text", text: school_message

      sign_out(school_manager)
      sign_in(student)

      visit internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
      page.has_no_content?(message_no_week)
      click_link("Voir l'annonce")
      find("a[href='#internship-application-form']").click
      page.has_no_content?("Je souhaite une semaine de stage")
      page.has_no_content?(student_message)
    end
  end

  test 'student bac pro try to apply to an offer while school manager has not open any internship week' do
    internship_offer = create(:bac_pro_internship_offer)
    school = create(:school, :with_school_manager, weeks: [])
    class_room = create(:class_room, :bac_pro, school: school)
    student = create(:student, school: school, class_room: class_room)
    message_no_week = "Attention, votre établissement n'a pas encore renseigné ses dates de stage."
    student_message = "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
    student_wish_message = "Je souhaite une semaine de stage"

    InternshipOffer.stub :nearby, InternshipOffer.all do
      sign_in(student)
      visit internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
      find "#alert-text", text: message_no_week
      click_link("Voir l'annonce")
      find("a[href='#internship-application-form']").click
      page.has_no_content? student_wish_message
      page.has_no_content? student_message

      visit internship_offers_path
      click_link("Voir l'annonce")
      find("a[href='#internship-application-form']").click
      find ".label", text: "Pourquoi ce stage me motive"
      page.find "input[name='commit']"
      sign_out(student)

      # Cron would find out and mail a notification
      cronjob_instance = Triggers::SchoolMissingWeeksReminder.new
      fake_notify_response = Minitest::Mock.new
      fake_notify_response.expect :call, true, [school]

      cronjob_instance.stub :notify, fake_notify_response do
        assert_equal [], cronjob_instance.enqueue_all
      end
    end
  end
end