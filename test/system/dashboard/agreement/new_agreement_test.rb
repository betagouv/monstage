require 'application_system_test_case'

module Dashboard
  class NewAgreementTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    def edit_is_allowed?(label:, id:nil)
      test_word = "test word"
      if label.present?
        id.present? ? fill_in(label, id: id, with: test_word) : fill_in(label, with: test_word)
        assert find_field(label).value == test_word
      end
      true
    end

    def edit_is_not_allowed?(label: nil, id: nil)
      if id.present?
        assert find("input##{id}")['disabled'] == 'true'
      end
      if label.present?
        assert find_field(label, disabled: true)
      end
      true
    end

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

      # Pages workflow
      visit dashboard_internship_offers_path
      find("div.my-auto span.red-notification-badge").click
      find('a.btn.btn-primary.btn-sm.ml-2.text-nowrap').click
      find('h1.h2', text: 'Votre convention de stage')
      find('h6.h6.test-header a', text: internship_offer.title)

      #Tool notes
      page.has_css?('.col-4 .tool-note')
      find('a.text-danger', text: 'Masquer les notes').click
      refute page.has_css?('.col-4 .tool-note')

      #Fields edition tests
      edit_is_allowed?(label: 'L’entreprise ou l’organisme d’accueil, représentée par',
                       id: 'internship_agreement_organisation_representative_full_name')
      edit_is_not_allowed?(label: "Nom du représentant de l’établissement",
                           id: 'internship_agreement_school_representative_full_name')
      edit_is_not_allowed?(label: "Nom de l’élève ou des élèves concerné(s)",
                           id: 'internship_agreement_student_full_name')
      edit_is_not_allowed?(label: "Classe",
                           id: 'internship_agreement_student_class_room')
      edit_is_not_allowed?(label: "Établissement d’origine",
                           id: 'internship_agreement_student_school')
      edit_is_allowed?(label: "Nom et qualité du responsable de l’accueil en milieu professionnel du tuteur",
                       id: 'internship_agreement_tutor_full_name')
      edit_is_not_allowed?(label: "Nom du ou (des) enseignant(s) chargé(s) de suivre le déroulement de séquence d’observation en milieu professionnel",
                           id: 'internship_agreement_main_teacher_full_name')
      edit_is_allowed?(label: "Dates de la séquence d’observation en milieu professionnel du",
                       id: 'internship_agreement_start_date')
      edit_is_allowed?(label: "Au",
                       id: 'internship_agreement_start_date')
      # find('select#internship_agreement_weekly_hours_start')
      # find("input[name='same_daily_planning']").checked?
      # find("input#same_daily_planning[type=\'checkbox\']").checked?
    end
  end
end