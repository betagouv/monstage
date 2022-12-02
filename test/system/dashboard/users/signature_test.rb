require 'application_system_test_case'

module Dashboard
  class SignatureTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    def code_script_enables(index)
      "document.getElementById('user-code-#{index}').disabled=false"
    end
    def code_script_assign(signature_phone_tokens, index)
      "document.getElementById('user-code-#{index}').value=#{signature_phone_tokens[index]}"
    end
    def enable_validation_button(id)
      "document.getElementById('#{id}').removeAttribute('disabled');"
    end

    test 'employer multiple signs and everything is ok' do
      # Brittle because of CI but shoud be working allright localy
      if ENV['RUN_BRITTLE_TEST']
        internship_agreement = create(:internship_agreement, :validated)
        employer = internship_agreement.employer
        weeks = [Week.find_by(number: 5, year: 2020), Week.find_by(number: 6, year: 2020)]
        internship_offer = create(:weekly_internship_offer, weeks: weeks, employer: employer)
        student = create(:student, school: create(:school, weeks: weeks))
        create(:school_manager, school: student.school)
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        motivation: 'au taquet',
                                        student: student,
                                        internship_offer: internship_offer)
        internship_application.validate!
        internship_agreement_2 = InternshipAgreement.last
        internship_agreement_2.complete!
        internship_agreement_2.validate!
        travel_to(weeks[0].week_date - 1.week) do
          sign_in(employer)

          visit dashboard_internship_agreements_path

          find('label', text: internship_agreement.student.presenter.full_name).click
          find('label', text: internship_application.student.presenter.full_name).click
          click_button('Signer en groupe (2)')

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 2 conventions de stage')
          find('input#phone_suffix').set('0612345678')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find("button#button-code-submit.fr-btn[disabled]")
          signature_phone_tokens = employer.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button("button-code-submit"))
          find("#button-code-submit").click
          find("input#submit[disabled='disabled']")
          within "dialog" do
            find('canvas').click
          end
          assert_difference 'Signature.count', 2 do
            find("input#submit").click
          end

          signature = internship_agreement.signatures.first
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          if Rails.application.config.active_storage.service == :local
            assert File.exist?(signature.local_signature_image_file_path)
          end

          signature = internship_agreement_2.signatures.first
          assert_equal internship_agreement_2.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          if Rails.application.config.active_storage.service == :local
            assert File.exist?(signature.local_signature_image_file_path)
          end

          assert_equal signature.employer.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et signer les conventions dématérialisées')
          first_label = all('a.fr-btn.disabled')[0].text
          assert_equal 'Déjà signée', first_label
          second_label = all('a.fr-btn.disabled')[1].text
          assert_equal 'Déjà signée', second_label
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
          all("a.fr-btn--secondary.button-component-cta-button")[0].click # Imprimer
          sleep 1.2
          student = internship_agreement.student
          file_name = "Convention_de_stage_#{student.first_name.upcase}_" \
                      "#{student.last_name.upcase}.pdf"
          assert File.exist? file_name
          File.delete file_name
          Dir[Signature::SIGNATURE_STORAGE_DIR + '/*'].each do |file|
            File.delete file
          end
        end
      end
    end

    test 'statistician single signs and everything is ok' do
      # Brittle because of CI but shoud be working allright localy
      if ENV['RUN_BRITTLE_TEST']
        employer = create(:statistician)
        weeks = [Week.find_by(number: 5, year: 2020), Week.find_by(number: 6, year: 2020)]
        internship_offer = create(:weekly_internship_offer, weeks: weeks, employer: employer)
        student = create(:student, school: create(:school, weeks: weeks))
        create(:school_manager, school: student.school)
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        motivation: 'au taquet',
                                        student: student,
                                        internship_offer: internship_offer)
        internship_application.validate!
        internship_agreement = InternshipAgreement.last
        internship_agreement.complete!
        internship_agreement.validate!
        travel_to(weeks[0].week_date - 1.week) do
          sign_in(employer)

          visit dashboard_internship_agreements_path

          click_button('Ajouter aux signatures')

          find('label', text: internship_agreement.student.presenter.full_name).click
          find('label', text: internship_application.student.presenter.full_name).click
          click_button('Signer')

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 1 convention de stage')
          find('input#phone_suffix').set('0612345678')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find("button#button-code-submit.fr-btn[disabled]")
          signature_phone_tokens = employer.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button("button-code-submit"))
          find("#button-code-submit").click
          find("input#submit[disabled='disabled']")
          within "dialog" do
            find('canvas').click
          end
          assert_difference 'Signature.count', 1 do
            find("input#submit").click
          end

          signature = internship_agreement.signatures.first
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          if Rails.application.config.active_storage.service == :local
            assert File.exist?(signature.local_signature_image_file_path)
          end


          assert_equal signature.employer.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et signer les conventions dématérialisées')
          first_label = all('a.fr-btn.disabled')[0].text
          assert_equal 'Déjà signée', first_label
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
          all("a.fr-btn--secondary.button-component-cta-button")[0].click # Imprimer
          sleep 1.2
          student = internship_agreement.student
          file_name = "Convention_de_stage_#{student.first_name.upcase}_" \
                      "#{student.last_name.upcase}.pdf"
          assert File.exist? file_name
          File.delete file_name
          Dir[Signature::SIGNATURE_STORAGE_DIR + '/*'].each do |file|
            File.delete file
          end
        end
      end
    end

    test 'school_manager multiple signs and everything is ok' do
      # Brittle because of CI but shoud be working allright localy
      if ENV['RUN_BRITTLE_TEST']
        internship_agreement = create(:internship_agreement, :validated)
        school_manager = internship_agreement.school_manager
        weeks = [Week.find_by(number: 5, year: 2020), Week.find_by(number: 6, year: 2020)]
        internship_offer = create(:weekly_internship_offer, weeks: weeks)
        school = school_manager.school
        student = create(:student, school: school, class_room: create(:class_room, school: school))
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        motivation: 'au taquet',
                                        student: student,
                                        internship_offer: internship_offer)
        internship_application.validate!
        internship_agreement_2 = InternshipAgreement.last
        internship_agreement_2.complete!
        internship_agreement_2.validate!
        travel_to(weeks[0].week_date - 1.week) do
          sign_in(school_manager)

          visit dashboard_internship_agreements_path

          find('label', text: internship_agreement.student.presenter.full_name).click
          find('label', text: internship_application.student.presenter.full_name).click
          click_button('Signer en groupe (2)')

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 2 conventions de stage')
          find('input#phone_suffix').set('0612345678')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find("button#button-code-submit.fr-btn[disabled]")
          signature_phone_tokens = school_manager.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button("button-code-submit"))
          find("#button-code-submit").click
          find("input#submit[disabled='disabled']")
          within "dialog" do
            find('canvas').click
          end
          assert_difference 'Signature.count', 2 do
            find("input#submit").click
          end

          signature = Signature.first
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal school_manager.id, signature.school_manager.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'school_manager', signature.signatory_role

          signature = Signature.last
          assert_equal internship_agreement_2.id, signature.internship_agreement.id
          assert_equal school_manager.id, signature.school_manager.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'school_manager', signature.signatory_role

          assert_equal signature.school_manager.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
          first_label = all('a.fr-btn.disabled')[0].text
          assert_equal 'Déjà signée', first_label
          second_label = all('a.fr-btn.disabled')[1].text
          assert_equal 'Déjà signée', second_label
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')

          all("a.fr-btn--secondary.button-component-cta-button")[0].click # Imprimer
          sleep 1.2
          student = internship_agreement.student
          file_name = "Convention_de_stage_#{student.first_name.upcase}_" \
                      "#{student.last_name.upcase}.pdf"
          assert File.exist? file_name
          File.delete file_name
          Dir[Signature::SIGNATURE_STORAGE_DIR + '/*'].each do |file|
            File.delete file
          end
        end
      end
    end

    test 'school_manager multiple clicks on interface' do
      internship_agreement = create(:internship_agreement, :validated)
      student1 = internship_agreement.student

      school_manager = internship_agreement.school_manager
      weeks = [Week.find_by(number: 5, year: 2020), Week.find_by(number: 6, year: 2020)]
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      school = school_manager.school
      student2 = create(:student, school: school, class_room: create(:class_room, school: school))
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      motivation: 'au taquet',
                                      student: student2,
                                      internship_offer: internship_offer)
      internship_application.validate!
      internship_agreement_2 = InternshipAgreement.last
      internship_agreement_2.complete!
      internship_agreement_2.validate!

      travel_to(weeks[0].week_date - 1.week) do
        sign_in(school_manager)

        visit dashboard_internship_agreements_path
        general_check_box = find("table input[data-action='group-signing#toggleSignThemAll']", visible: false)
        find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        refute general_check_box.checked?

        find('label', text: student1.presenter.full_name).click
        find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer')
        first_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        assert first_right_button.disabled?
        second_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        refute second_right_button.disabled?

        find('label', text: student2.presenter.full_name).click
        find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer en groupe (2)')
        assert general_check_box.checked?
        first_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        assert first_right_button.disabled?
        second_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        assert second_right_button.disabled?

        find("label[for='select-general-internship-agreements']").click
        general_button = find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer')
        assert general_button.disabled?
        refute general_check_box.checked?
        first_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        refute first_right_button.disabled?
        second_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        refute second_right_button.disabled?
        checkbox_1 = find("input[id='user_internship_agreement_id_#{internship_agreement.id}_checkbox']", visible: false)
        refute checkbox_1.checked?
        checkbox_2 = find("input[id='user_internship_agreement_id_#{internship_agreement_2.id}_checkbox']", visible: false)
        refute checkbox_2.checked?

        find('label', text: student1.presenter.full_name).click
        find('label', text: student2.presenter.full_name).click
        find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer en groupe (2)')
        assert general_check_box.checked?
      end
    end
  end
end
