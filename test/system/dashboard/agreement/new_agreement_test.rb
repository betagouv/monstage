require 'application_system_test_case'

module Dashboard
  class NewAgreementTest < ApplicationSystemTestCase
    include ThirdPartyTestHelpers


    def field_edit_is_allowed?(label:, id: nil)
      test_word = 'test word'
      if label.present?
        id.present? ? fill_in(label, id: id, with: test_word) : fill_in(label, with: test_word)
        assert %r{#{test_word}} =~ find_field(label).value
      end
      true
    end

    def field_edit_is_not_allowed?(label: nil, id: nil)
      if id.present?
        assert find("input##{id}")['disabled'] == 'true',
               "fail to find disabled input for #{id}"
      end
      if label.present?
        assert find_field(label, disabled: true),
               "fail to find label for #{label}"

      end
    end

    def fill_in_trix_editor(id, with:)
      field = find(:xpath, "//trix-editor[@id='#{id}']")

      with.split('').each { |c| field.native.send_keys(c) }
    end

    def find_trix_editor(id)
      find(:xpath, "//*[@id='#{id}']")
    end

    def assert_trix_editor_editable(id)
      tested_word = 'test_word'
      fill_in_trix_editor id, with: tested_word
      assert %r{#{tested_word}} =~ find_trix_editor(id).value
    end

    def refute_trix_editor_editable(id)
      find("##{id}[contenteditable=false]")
    end

    def select_editable?(id, should_be_selectable)
      find("select[id='#{id}']")['disabled'] == should_be_selectable
    end

    test 'as Employer, I can edit my own fields only' do
      employer = create(:employer)
      # School_track is 'troisieme_générale'
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
      find('.test-header a', text: internship_offer.title)

      #Tool notes
      page.has_css?('.col-4 .tool-note')
      find('.btn.btn-link', text: 'Masquer les notes').click
      refute page.has_css?('.col-4 .tool-note')
      find('.btn.btn-link', text: 'Afficher les notes').click

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
      refute execute_script("return document.getElementById('same_daily_planning').checked")
      execute_script("document.getElementById('same_daily_planning').checked = false")
      refute execute_script("return document.getElementById('same_daily_planning').checked")
      execute_script("document.getElementById('daily-planning').classList.remove('d-none')")

      within '.schedules' do
        assert_text('Lundi')
        assert_text('Samedi')
        select_editable?('internship_agreement_new_daily_hours_samedi_start', false)
        select_editable?('internship_agreement_new_daily_hours_samedi_end', false)
      end


      # School_track 'troisieme generale' hides some fields
      assert_no_selector('label', text: 'Compétences visées')
      assert_no_selector('label', text: 'Modalités de la concertation')

      # Trix fields tests
      %w[
        internship_agreement_complementary_terms_rich_text
      ].each do |trix_field_id|
        assert_trix_editor_editable(trix_field_id)

      end
      %w[
        internship_agreement_activity_rating_rich_text
      ].each do |trix_field_id|
        refute_trix_editor_editable(trix_field_id)
      end

    end

    test 'as School Manager, I can edit my own fields only' do
      internship_offer = create(:weekly_internship_offer)
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
      field_edit_is_allowed?(label: 'Nom de l’élève ou des élèves concerné(s)',
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

      # Trix fields tests
      %w[
        internship_agreement_activity_scope_rich_text
      ].each do |trix_field_id|
        refute_trix_editor_editable(trix_field_id)
      end
      %w[
        internship_agreement_activity_rating_rich_text
        internship_agreement_complementary_terms_rich_text
      ].each do |trix_field_id|
        assert_trix_editor_editable(trix_field_id)
      end
    end

    test 'as Main Teacher, I can edit my own fields only' do
      internship_offer = create(:weekly_internship_offer)
      school           = create(:school, :with_school_manager, :with_agreement_presets)
      class_room       = create(:class_room, school: school)
      main_teacher     = create(:main_teacher, school: school, class_room_id: class_room.id)
      student          = create(:student, school: school, class_room: class_room)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(main_teacher)
      visit new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)

      #Fields edition tests
      field_edit_is_not_allowed?(label: 'L’entreprise ou l’organisme d’accueil, représentée par',
                                id: 'internship_agreement_organisation_representative_full_name')
      field_edit_is_not_allowed?(label: 'L’établissement d’enseignement scolaire, représenté par',
                                id: 'internship_agreement_school_representative_full_name')
      field_edit_is_not_allowed?(label: 'Nom de l’élève ou des élèves concerné(s)',
                                id: 'internship_agreement_student_full_name')
      field_edit_is_allowed?(label: 'Classe',
                                id: 'internship_agreement_student_class_room')
      field_edit_is_not_allowed?(label: 'Établissement d’origine',
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

      # Trix fields tests
      %w[
        internship_agreement_activity_scope_rich_text
        internship_agreement_complementary_terms_rich_text
      ].each do |trix_field_id|
        refute_trix_editor_editable(trix_field_id)
      end
      %w[
        internship_agreement_activity_rating_rich_text
      ].each do |trix_field_id|
        assert_trix_editor_editable(trix_field_id)
      end
    end


    test 'mere teachers cannot reach Convention à signer' do
      internship_offer = create(:weekly_internship_offer)
      school           = create(:school, :with_school_manager)
      class_room       = create(:class_room, school: school)
      teacher          = create(:teacher, school: school, class_room: class_room)
      student          = create(:student, school: school, class_room: class_room)
      ability          = Ability.new(teacher)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(teacher)
      visit teacher.custom_dashboard_path
      assert page.has_content?('Semaines')
      assert ability.cannot?(:create, InternshipAgreement)
      refute page.has_content?('Conventions de stage')
    end

    #since they do not care about the same students
    test 'main_teachers cannot see other\'s main_teachers agreements' do
      internship_offer = create(:weekly_internship_offer)
      school           = create(:school, :with_school_manager)
      class_room       = create(:class_room, school: school)
      class_room_2     = create(:class_room, school: school)
      main_teacher     = create(:main_teacher, school: school, class_room: class_room)
      main_teacher_2   = create(:main_teacher, school: school, class_room: class_room_2)
      student          = create(:student, school: school, class_room: class_room)
      ability          = Ability.new(main_teacher_2)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(main_teacher_2)
      visit main_teacher_2.custom_dashboard_path
      find("li.nav-item a.nav-link.pl-1.pr-1.py-4", text: main_teacher_2.dashboard_name).click
      assert page.has_content?('Semaines')
      assert ability.can?(:create, InternshipAgreement)
      assert page.has_content?('Conventions de stage')
      click_link('Conventions de stage')
      refute page.has_content?(student.first_name)
    end
  end
end
