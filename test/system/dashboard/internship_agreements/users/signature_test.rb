require 'application_system_test_case'

module Dashboard::InternshipAgreements::Users
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

    test 'employer signs and everything is ok' do
      if ENV['RUN_BRITTLE_TEST']
        travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
          internship_agreement = create(:internship_agreement, :validated)
          employer = internship_agreement.employer
          sign_in(employer)

          visit dashboard_internship_agreements_path

          click_on 'Signer la convention'

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
          find('input#phone-input').set('0612345678')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find("button#button-code-submit-#{internship_agreement.id}.fr-btn[disabled]")
          signature_phone_tokens = employer.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button("button-code-submit-#{internship_agreement.id}"))
          find("#button-code-submit-#{internship_agreement.id}").click
          find("input#submit-#{internship_agreement.id}[disabled='disabled']")
          within "dialog" do
            find('canvas').click
          end
          assert_difference 'Signature.count', 1 do
            find("input#submit-#{internship_agreement.id}").click
          end

          signature = Signature.last
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role

          assert_equal signature.employer.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
          find('a.fr-btn.disabled', text: 'Signée, en attente')
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
          find("a.fr-btn--secondary.button-component-cta-button").click # Imprimer
          sleep 0.5
          assert File.exists?('Convention_de_stage_RICK_ROLL.pdf')
          File.delete('Convention_de_stage_RICK_ROLL.pdf')
        end
      end
    end

    test 'school_manager signs and everything is ok' do
      if ENV['RUN_BRITTLE_TEST'] # Brittle because of CI but working allright localy
        travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
          internship_agreement = create(:internship_agreement, :validated)
          school_manager = internship_agreement.school_manager
          sign_in(school_manager)

          visit dashboard_internship_agreements_path

          click_on 'Signer la convention'

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
          find('input#phone-input').set('0612345678')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find("button#button-code-submit-#{internship_agreement.id}.fr-btn[disabled]")
          signature_phone_tokens = school_manager.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button("button-code-submit-#{internship_agreement.id}"))
          find("#button-code-submit-#{internship_agreement.id}").click
          find("input#submit-#{internship_agreement.id}[disabled='disabled']")
          within "dialog" do
            find('canvas').click
          end
          assert_difference 'Signature.count', 1 do
            find("input#submit-#{internship_agreement.id}").click
          end

          signature = Signature.last
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal school_manager.id, signature.school_manager.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'school_manager', signature.signatory_role

          assert_equal signature.school_manager.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et bientôt signer les conventions dématérialisées')
          find('a.fr-btn.disabled', text: 'Signée, en attente')
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
          refute File.exists?('Convention_de_stage_RICK_ROLL.pdf')
          find("a.fr-btn--secondary.button-component-cta-button").click # Imprimer
          sleep 0.5
          assert File.exists?('Convention_de_stage_RICK_ROLL.pdf')
          File.delete('Convention_de_stage_RICK_ROLL.pdf')
        end
      end
    end
  end
end
