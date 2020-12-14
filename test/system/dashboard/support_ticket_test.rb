require 'application_system_test_case'


class SupportTicketTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  test 'as School Manager, I can send a support ticket with remote internship fields informations' do
    school_manager = create(:school, :with_school_manager).school_manager
    sign_in(school_manager)

    visit school_manager.custom_dashboard_path
    click_link('Contactez-nous !')
    find('.h4.text-body', text: "Contactez-nous, nous vous mettrons en lien avec nos associations partenaires.")

    click_on "Envoyer la demande"

    find('label', text: "L'un des trois modes 'Semaine digitale', 'Webinaire' ou 'En présentiel' doivent être sélectionnés")
    find('label', text: "Il faudrait sélectionner au moins une semaine cible pour vos étudiants")
    find('label', text: "Il manque à cette demande le nombre d'étudiants concernés")
    find('label', text: "Le nombre d'étudiants devrait être chiffré")
    assert_enqueued_with(job: SupportTicketJobs::SchoolManager) do
      check 'support_ticket[webinar]'
      selectable_week = Week.selectable_from_now_until_end_of_school_year.first
      find("label[for=\"support_ticket_week_ids_#{selectable_week.id}_checkbox\"]").click
      select "2 classes"
      fill_in("support_ticket_students_quantity", with: 5)
      click_on "Envoyer la demande"
    end
  end

  test 'as Employer, I can send a support ticket with remote internship fields informations' do
    employer = create(:employer)
    sign_in(employer)

    visit employer.custom_dashboard_path
    click_link('Contactez-nous !')
    find('.h4.text-body', text: "Vous souhaitez participer à la mise en place de stages à distance ?")

    click_on "Envoyer la demande"
    find('label', text: "L'un des trois modes 'Semaine digitale', 'Webinaire' ou 'En présentiel' doivent être sélectionnés")
    find('label', text: "Il faudrait sélectionner au moins une semaine cible pour vos étudiants")
    find('label', text: "Il manque à cette demande le nombre d'intervenants")
    find('label', text: "Il manque à cette demande le nombre de métiers abordés")
    assert_enqueued_with(job: SupportTicketJobs::Employer) do
      check 'support_ticket[webinar]'
      selectable_week = Week.selectable_from_now_until_end_of_school_year.first
      find("label[for=\"support_ticket_week_ids_#{selectable_week.id}_checkbox\"]").click
      select "1 intervenant"
      select "1 métier"
      click_on "Envoyer la demande"
    end
  end


  test 'as Main Teacher, my default page do not shxo support ticket with remote internship fields informations' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school: school)
    sign_in(main_teacher)

    visit main_teacher.custom_dashboard_path
    refute page.has_content?("Contactez-nous !")
  end
end

