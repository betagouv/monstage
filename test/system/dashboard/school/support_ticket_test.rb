require 'application_system_test_case'

module Dashboard
  class SupportTicketTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    test 'as School Manager, I can send a support ticket with remote internship fields informations' do
      school = create(:school, :with_school_manager)
      school_manager = school.school_manager
      sign_in(school_manager)

      visit root_path
      within('header') do
        find("a.nav-link", text: school_manager.dashboard_name).click
      end
      find('h2.h2', text: "Contactez-nous pour entrer en contact avec nos associations partenaires qui coordonnent l'effort")
    end

    test 'as Main Teacher, my default page do not shxo support ticket with remote internship fields informations' do
      school = create(:school, :with_school_manager)
      main_teacher = create(:main_teacher, school: school)
      sign_in(main_teacher)

      visit root_path
      within('header') do
        find("a.nav-link", text: main_teacher.dashboard_name).click
      end
      refute page.has_content?("Contactez-nous pour entrer en contact avec nos associations partenaires qui coordonnent l'effort")
    end
  end
end
