require 'test_helper'

class NavbarTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @school = create(:school, :with_school_manager, :with_weeks)
  end

  test 'visitor navbar' do
    get root_path
    assert_select("li a.fr-link.fr-icon-lock-line", text: 'Connexion', count: 1)
    assert_select("li a.fr-link.fr-icon-user-line", text: 'Créer mon compte', count: 1)
  end

  test 'employer' do
    employer = create(:employer)
    sign_in(employer)
    get employer.custom_dashboard_path
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon compte', count: 1)
  end

  test 'main_teacher' do
    main_teacher = create(:main_teacher,
                          school: @school,
                          class_room: create(:class_room, school: @school))
    sign_in(main_teacher)
    get main_teacher.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      main_teacher.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Ma classe', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 0)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 0)
  end

  test 'other' do
    other = create(:other, school: @school)
    create(:class_room, school: @school)
    sign_in(other)
    get other.custom_dashboard_path
    follow_redirect!
    puts '---writing html in debug_file.html ---'
    puts ''
    html = Nokogiri::HTML(response.body)
    File.open('debug_file.html', 'w+') { |f| f.write html } 
    puts '----------------------------------------'

    assert_select( '#classes-panel a[href=?]',
                    new_dashboard_school_class_room_path)
    assert_select("a.small.fr-raw-link.fr-tag.fr-tag--sm[href=?]", 
                  dashboard_school_class_room_students_path(@school, @school.class_rooms.first))
                                # href="/tableau-de-bord/ecoles/112/classes/39/eleves">3e A</a>)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Mon établissement', count: 1)
  end

  test 'operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get operator.custom_dashboard_path
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: operator.dashboard_name, count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Statistiques', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 1)
  end

  test 'school_manager' do
    school_manager = @school.school_manager
    sign_in(school_manager)
    get school_manager.custom_dashboard_path
    follow_redirect!
    assert_select(
      'li a.fr-link[href=?]',
      school_manager.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Mon établissement', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon établissement', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 0)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 0)
  end

  test 'student' do
    student = create(:student)
    sign_in(student)
    get student.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      student.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: student.dashboard_name, count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Candidatures / Réponses', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 0)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 0)
  end

  test 'teacher' do
    teacher = create(:teacher,
                     school: @school,
                     class_room: create(:class_room, school: @school))
    sign_in(teacher)
    get teacher.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      teacher.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Ma classe', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Ma classe', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 0)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 0)
  end

  test 'statistician' do
    statistician = create(:statistician)
    sign_in(statistician)
    get statistician.custom_dashboard_path
    assert_select('li a.fr-link.text-decoration-none.active', count: 1, text: 'Statistiques')
    assert_select('li a.fr-link.text-decoration-none.active', text: statistician.dashboard_name, count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 1)
  end

  test 'ministry statistician' do
    ministry_statistician = create(:ministry_statistician)
    sign_in(ministry_statistician)
    get ministry_statistician.custom_dashboard_path
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Statistiques nationales', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: ministry_statistician.dashboard_name, count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 1)
  end

  test 'education statistician' do
    education_statistician = create(:education_statistician)
    sign_in(education_statistician)
    get education_statistician.custom_dashboard_path
    assert_select('li a.fr-link.text-decoration-none.active', count: 1, text: 'Statistiques')
    assert_select('li a.fr-link.text-decoration-none.active', text: education_statistician.dashboard_name, count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Accueil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Recherche', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mes offres', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Mon profil', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'Espaces', count: 1)
    assert_select("li a.fr-link.mr-4", text: 'équipe'.capitalize, count: 1)
  end
end