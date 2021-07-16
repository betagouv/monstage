# frozen_string_literal: true

require 'application_system_test_case'

class EmailUpdateFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  # include ::EmailSpamEuristicsAssertions

  test 'student updates her email' do
    password  = 'kikoolol'
    email     = 'fourcade.m@gmail.com'
    alt_email = 'another_email@free.fr'
    user = create(:student, email: email,
                            password: password,
                            phone: nil,
                            confirmed_at: Time.now.utc)
    sign_in(user)

    assert_changes -> { user.reload.unconfirmed_email } do
      visit account_path
      fill_in('Adresse électronique (ex : mon@exemple.fr)', with: alt_email)
      click_on('Enregistrer')
      success_message = find('#alert-text').text
      assert_equal success_message,
                  "Compte mis à jour avec succès. Un courriel a été envoyé " \
                  "à l'ancienne adresse électronique (e-mail). Veuillez " \
                  "cliquer sur le lien contenu dans le courriel pour confirmer" \
                  " votre nouvelle adresse électronique (e-mail)."
    end
    visit account_path
    assert_equal alt_email, find('#user_unconfirmed_email').value
    assert_text(
      "Cet email n'est pas encore confirmé : veuillez consulter vos emails"
    )
    find_link( text: "Vous n'avez pas reçu le message d'activation ?" ).click
    find('label[for=select-channel-email]').click
    execute_script("document.getElementById('user_email').value = '#{alt_email}';")

    click_on('Renvoyer')
    user.confirm
    visit account_path
    assert_equal alt_email, find('#user_email').value
  end
end
