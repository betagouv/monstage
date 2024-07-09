require 'application_system_test_case'

class WithTeamTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include TeamAndAreasHelper
  
  test 'workflow for making a team is ok' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    create :team_member_invitation,
            inviter_id: employer_1.id,
            invitation_email: employer_2.email
    sign_in(employer_2)
    visit employer_2.after_sign_in_path
    click_button 'Oui'
    assert_equal 2, all('span.fr-badge.fr-badge--no-icon.fr-badge--success', text: "INSCRIT").count
    assert_equal 2, employer_1.team.team_size
    assert_equal 2, employer_2.team.team_size
    assert_equal 4 , AreaNotification.count
  end

  test 'adding an extra collegue make area_notifications count ok' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    offer = create_internship_offer_visible_by_two(employer_1, employer_2)
    assert_equal 4 , AreaNotification.count
    employer_3 = create(:employer)
    assert_equal 4 , AreaNotification.count
    create :team_member_invitation,
            inviter_id: employer_1.id,
            invitation_email: employer_3.email
    sign_in(employer_3)
    visit employer_3.after_sign_in_path
    assert_difference -> { AreaNotification.count }, 5 do
      click_button 'Oui'
    end
  end

  test 'adding an extra area make area_notifications count ok' do
    employer_1 = create(:employer, first_name: 'Maxime')
    employer_2 = create(:employer, first_name: 'Etienne')
    space_name = 'Espace 2'
    create :team_member_invitation,
    inviter_id: employer_1.id,
    invitation_email: employer_2.email
    sign_in(employer_2)
    visit employer_2.after_sign_in_path
    assert_equal 0, AreaNotification.all.count
    click_button 'Oui'
    find('li a', text: 'Espaces').click
    assert_equal 4, AreaNotification.all.count # (one minimum area per user )* 2 team members
    click_button 'Créer un nouvel espace'
    fill_in('Nom de l\'espace', with: space_name)
    find('input[type="submit"]').click
    find('h1', text: space_name)
    assert_equal 6, AreaNotification.all.count # (one minimum area per user + new one )* 2 team members
    find('label', text: employer_1.name).click
    find('label', text: employer_1.name).click
    find('label', text: employer_1.name).click
    assert_equal 6, AreaNotification.all.count

    click_link 'Tous mes espaces'
    new_area = InternshipOfferArea.last
    notif_maxime = AreaNotification.find_by(user_id: employer_1.id, internship_offer_area_id: new_area.id)
    refute notif_maxime.notify
    notif_etienne = AreaNotification.find_by(user_id: employer_2.id, internship_offer_area_id: new_area.id)
    assert notif_etienne.notify
  end

  test 'space destruction make area_notifications count ok' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    internship_offer = create_internship_offer_visible_by_two(employer_1, employer_2)
    sign_in(employer_2)
    visit employer_2.after_sign_in_path
    assert_equal 4, AreaNotification.all.count
    find('li a', text: 'Espaces').click
    all("tbody tr td.area-name a").each do |el|
      el.text.in?([employer_1.current_area.name, employer_2.current_area.name])
    end
    find("button[aria-controls='fr-modal-area-destroy-dialog-#{employer_2.current_area_id}']").click
    find('input[type="submit"]').click
    find('h1', text: 'Nouvel espace')
    find 'tbody tr td.area-name a'
    assert_equal 1, InternshipOfferArea.all.count
    assert_equal 2, AreaNotification.all.count
  end
end