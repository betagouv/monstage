require 'application_system_test_case'
include ActiveJob::TestHelper
class InternshipApplicationStudentFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  test 'visitor navbar' do
    visit root_path
    assert_selector("li a.fr-link.fr-icon-lock-line", text: 'Connexion', count: 1)
    assert_selector("li a.fr-link.fr-icon-user-line", text: 'Créer mon compte', count: 1)
  end

  test 'employer navbar' do
    employer = create(:employer)
    sign_in employer
    visit root_path
    assert_selector("li a.fr-link.mr-4.active", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon tableau de bord', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon compte', count: 1)
  end

  test 'student navbar' do
    student = create(:student)
    sign_in student
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Candidatures', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

  test 'school_manager navbar' do
    school = create(:school, :with_school_manager)
    sign_in school.school_manager
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon établissement', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

  test 'operator navbar' do
    operator = create(:operator)
    user_operator = create(:user_operator, operator: operator)
    sign_in user_operator
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Statistiques', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

  test 'teacher navbar' do
    school = create(:school, :with_school_manager)
    teacher = create(:teacher, school: school)
    sign_in teacher
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon établissement', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

  test 'departemental statistician navbar' do
    statistician = create(:statistician)
    sign_in statistician
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Statistiques', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

  test 'ministry statistician navbar' do
    ministry_statistician = create(:ministry_statistician)
    sign_in ministry_statistician
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Statistiques nationales', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

  test 'education statistician navbar' do
    education_statistician = create(:education_statistician)
    sign_in education_statistician
    visit root_path
    assert_selector("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Statistiques', count: 1)
    assert_selector("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
  end

end