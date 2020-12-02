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
      click_link('Contactez-nous !')
      find('.h4.text-body', text: "Contactez-nous, nous vous mettrons en lien avec nos associations partenaires.")
    end

    test 'as Main Teacher, my default page do not shxo support ticket with remote internship fields informations' do
      school = create(:school, :with_school_manager)
      main_teacher = create(:main_teacher, school: school)
      sign_in(main_teacher)

      visit root_path
      within('header') do
        find("a.nav-link", text: main_teacher.dashboard_name).click
      end
      refute page.has_content?("Contactez-nous !")
    end
  end
end
