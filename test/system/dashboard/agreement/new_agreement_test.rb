require 'application_system_test_case'

module Dashboard
  class NewAgreementTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include CapybaraHelpers

    test 'as Employer, I can edit my own fields only' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(employer)

      visit new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)
      find('h1.h2', text: 'Votre convention de stage')
      find('h6.h6.test-header a', text: internship_offer.title)

      #Tool notes
      page.has_css?('.col-4 .tool-note')
      find('a.text-danger', text: 'Masquer les notes').click
      refute page.has_css?('.col-4 .tool-note')
      find('a', text: 'Afficher les notes').click

      #Fields edition tests
      field_edit_is_allowed?(label: 'L’entreprise ou l’organisme d’accueil, représentée par',
                             id: 'internship_agreement_organisation_representative_full_name')
      field_edit_is_not_allowed?(label: 'L’établissement d’enseignement scolaire, représenté par',
                                 id: 'internship_agreement_school_representative_full_name')
      field_edit_is_not_allowed?(label: 'Nom de l’élève ou des élèves concerné(s)',
                                 id: 'internship_agreement_student_full_name')
      field_edit_is_not_allowed?(label: 'Classe',
                                 id: 'internship_agreement_student_class_room')
      field_edit_is_not_allowed?(label: 'Établissement d’origine',
                                 id: 'internship_agreement_student_school')
      field_edit_is_allowed?(label: "Nom et qualité du responsable de l’accueil en milieu professionnel du tuteur",
                             id: 'internship_agreement_tutor_full_name')
      field_edit_is_not_allowed?(label: "Nom du ou (des) enseignant(s) chargé(s) de suivre le déroulement de séquence d’observation en milieu professionnel",
                                 id: 'internship_agreement_main_teacher_full_name')
      field_edit_is_allowed?(label: "Dates de la séquence d’observation en milieu professionnel du",
                             id: 'internship_agreement_date_range')
      #Schedule fields tests
      assert execute_script("return document.getElementById('same_daily_planning').checked")
      execute_script("document.getElementById('same_daily_planning').checked = false")
      refute execute_script("return document.getElementById('same_daily_planning').checked")
      execute_script("document.getElementById('daily-planning').classList.remove('d-none')")

      within '.schedules' do
        assert_text('Lundi')
        assert_text('Samedi')
        select_editable?('internship_agreement_new_daily_hours_samedi_start', true)
        select_editable?('internship_agreement_new_daily_hours_samedi_end', true)
      end

      # Trix fields tests
      %w[
        internship_agreement_activity_scope_rich_text
        internship_agreement_activity_preparation_rich_text
        internship_agreement_activity_learnings_rich_text
      ].each do |trix_field_id|
        assert trix_editor_editable?(trix_field_id, true)
      end
      %w[
        internship_agreement_activity_rating_rich_text
        internship_agreement_financial_conditions_rich_text
      ].each do |trix_field_id|
        assert trix_editor_editable?(trix_field_id, false)
      end
    end

    test 'as School Manager, I can edit my own fields only' do
      # t1 = Time.now
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(school.school_manager)
      visit new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)

      #Fields edition tests
      field_edit_is_not_allowed?(label: 'L’entreprise ou l’organisme d’accueil, représentée par',
                                 id: 'internship_agreement_organisation_representative_full_name')
      field_edit_is_allowed?(label: 'L’établissement d’enseignement scolaire, représenté par',
                             id: 'internship_agreement_school_representative_full_name')
      field_edit_is_not_allowed?(label: 'Nom de l’élève ou des élèves concerné(s)',
                             id: 'internship_agreement_student_full_name')
      field_edit_is_allowed?(label: 'Classe',
                             id: 'internship_agreement_student_class_room')
      field_edit_is_allowed?(label: 'Établissement d’origine',
                             id: 'internship_agreement_student_school')
      field_edit_is_not_allowed?(label: "Nom et qualité du responsable de l’accueil en milieu professionnel du tuteur",
                                 id: 'internship_agreement_tutor_full_name')
      field_edit_is_allowed?(label: "Nom du ou (des) enseignant(s) chargé(s) de suivre le déroulement de séquence d’observation en milieu professionnel",
                             id: 'internship_agreement_main_teacher_full_name')
      field_edit_is_not_allowed?(label: "Dates de la séquence d’observation en milieu professionnel du",
                                 id: 'internship_agreement_date_range')
      #Schedule fields tests
      execute_script("document.getElementById('same_daily_planning').checked = false")
      execute_script("document.getElementById('daily-planning').classList.remove('d-none')")
      within '.schedules' do
        select_editable?('internship_agreement_weekly_hours_start', false)
        select_editable?('internship_agreement_weekly_hours_end', false)
      end

      # Trix fields tests
      %w[
        internship_agreement_activity_scope_rich_text
        internship_agreement_activity_preparation_rich_text
        internship_agreement_activity_learnings_rich_text
      ].each do |trix_field_id|
        assert trix_editor_editable?(trix_field_id, false)
      end
      %w[
        internship_agreement_activity_rating_rich_text
        internship_agreement_financial_conditions_rich_text
      ].each do |trix_field_id|
        assert trix_editor_editable?(trix_field_id, true)
      end
    end
  end
end