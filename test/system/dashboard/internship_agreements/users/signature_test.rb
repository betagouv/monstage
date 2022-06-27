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
    def script_assign(id, value)
      "document.getElementById('#{id}').value=#{value}"
    end
    def enable_validation_button(id)
      "document.getElementById('#{id}').removeAttribute('disabled');"
    end

    test 'employer signs and everything is ok' do
      travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
        internship_agreement = create(:troisieme_generale_internship_agreement, :validated)
        employer = internship_agreement.employer
        sign_in(employer)

        visit dashboard_internship_agreements_path

        click_on 'Signer la convention'

        find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer la convention de stage')
        find('input#phone-input').set('0612345678')
        click_button('Recevoir un code')

        find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
        find('button.fr-btn[disabled]')
        signature_phone_tokens = employer.reload.signature_phone_token.split('')
        (0..5).to_a.each do |index|
          execute_script(code_script_enables(index))
          execute_script(code_script_assign(signature_phone_tokens, index))
        end
        execute_script(enable_validation_button("button-code-submit-#{internship_agreement.id}"))
        str_signature = File.read(
          Rails.root.join( *%w[test fixtures files signature.json] )
        )
        within "dialog" do
          find("#button-code-submit-#{internship_agreement.id}").click
          find("input#handwrite_signature_#{internship_agreement.id}").set(JSON.parse(str_signature).to_json)
          execute_script(enable_validation_button("submit-#{internship_agreement.id}"))
        end
        assert_difference 'Signature.count', 1 do
          find("#submit-#{internship_agreement.id}").click
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
      end
    end
  end
end
