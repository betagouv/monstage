require 'application_system_test_case'

class UserUpdateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'student can update his email' do
    student = create(:student, phone: '+330623042585')
    sign_in(student)
    visit account_path

    user_email_selector = find(:css, "#user_email")
    assert user_email_selector.value == student.email
    fill_in('user[email]', with: "baboo@free.fr")
    click_on 'Enregistrer'
    success_message = find('#alert-text').text
    assert success_message == 'Compte mis à jour avec succès. Veuillez confirmer votre nouvelle Adresse électronique (e-mail).'
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

  test 'student will not update his phone number with a wrong formatted phone number' do
    student_2 = create(:student)
    sign_in(student_2)
    visit account_path

    user_phone_selector = find(:css, '#phone-input')
    assert user_phone_selector.value == '+33'
    fill_in('user[phone]', with: '+3306230')
    click_on 'Enregistrer'
    alert_message = 'test'
    within '#error_explanation' do
      alert_message = find('label').text
    end
    assert alert_message == 'Veuillez modifier le numéro de téléphone mobile'
  end
end