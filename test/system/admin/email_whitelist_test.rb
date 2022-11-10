require 'application_system_test_case'

module Dashboard
  class EmailWhitelistTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'admin canno create email whitelist without group' do
      admin = create(:god)
      sign_in(admin)
      visit '/admin'
      all('.nav-link', text: 'Courriels autorisés des référents centraux').first.click
      click_on 'Ajouter nouveau'
      fill_in 'Email', with: 'test@ministere.fr'
      click_on 'Enregistrer'
      assert_text 'Courriel autorisé du référent central : n\'a pas pu être créé(e)'
    end

    test 'admin can create email whitelist' do
      admin = create(:god)
      group = create(:group, is_public: true)
      assert group.is_public?
      sign_in(admin)
      visit '/admin'
      all('.nav-link', text: 'Courriels autorisés des référents centraux').first.click
      find('a.nav-link span', text: 'Ajouter nouveau').click
      fill_in 'Email', with: 'test@ministere.fr'
      within('.control-group.row.mb-3.belongs_to_association_type.group_field') do
        find('label.dropdown-toggle').click
      end
      find('li a', text: group.name).click
      click_on 'Enregistrer'
      assert_text 'Courriel autorisé du référent central : créé(e) avec succès'
    end
  end
end
