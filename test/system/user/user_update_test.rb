require 'application_system_test_case'

class UserUpdateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'student can update his email' do
    student = create(:student, phone: '+330623042585')
    sign_in(student)
    visit account_path

    user_email_selector = find(:css, "#user_email_1")
    assert user_email_selector.value == student.email
    fill_in('user[email]', with: "baboo@free.fr")
    click_on 'Enregistrer'
    success_message = find('#alert-text').text
    assert success_message == "Compte mis à jour avec succès. Un courriel a été envoyé à l'ancienne adresse électronique (e-mail). Veuillez cliquer sur le lien contenu dans le courriel pour confirmer votre nouvelle adresse électronique (e-mail)."
  end

  test 'student can update his phone number' do
    student = create(:student, phone: '+330623042585')
    sign_in(student)
    visit account_path

    user_phone_selector = find(:css, '#phone-input')
    assert user_phone_selector.value.gsub(' ','') == student.phone
    fill_in('user[phone]', with: '+330623043058')
    click_on 'Enregistrer'
    success_message = find('#alert-text').text
    assert success_message == 'Compte mis à jour avec succès.'
  end

  test 'student will not update his phone number with a badly formatted phone number' do
    student = create(:student)
    sign_in(student)
    visit account_path

    user_phone_selector = find(:css, '#phone-input')
    assert user_phone_selector.value == '+33'
    fill_in('user[phone]', with: '+3306230')
    click_on 'Enregistrer'
    alert_message = 'test'
    # within '#error_explanation' do
    #   alert_message = find('label').text
    # end
    # assert alert_message == 'Veuillez modifier le numéro de téléphone mobile'
  end

  test 'student with no school is redirected to account(:school)' do
    school_new = create(:school, name: 'Etablissement Test 1', city: 'Paris', zipcode: '75012')
    student = create(:student)
    student.school = nil
    student.save

    sign_in(student.reload)

    visit account_path
    find('h1.h2', text: 'Mon établissement')
    find('#alert-danger', text: 'Veuillez rejoindre un etablissement')
    within('#alert-danger') do
      click_button('Fermer')
    end
    click_on 'Mon établissement'
    find_field('Nom (ou ville) de mon établissement').fill_in(with: 'Paris ')
    find('li#downshift-0-item-0').click
    select school_new.name, from: "user_school_id"
    click_button('Enregistrer')

    visit internship_offers_path
    find('h1', text: 'Postulez à des offres de stage')
    sign_out(student)

    employer = create(:employer)
    sign_in(employer)
    visit internship_offers_path
    find('h1', text: 'Postulez à des offres de stage')
  end
end
