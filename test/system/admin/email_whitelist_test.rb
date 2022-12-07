require 'application_system_test_case'

module Dashboard
  class EmailWhitelistTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'admin cannot create email whitelist without any group' do
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
      click_link('Choisir tout')
      click_on 'Enregistrer'
      assert_text 'Courriel autorisé du référent central : créé(e) avec succès'
    end
  end
end
