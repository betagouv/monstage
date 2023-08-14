require 'test_helper'

module Dashboard
  module InternshipOfferAreas
    class CreateAreaControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'POST create_area when employer is alone' do
        employer = create(:employer)
        assert_equal 1, employer.internship_offer_areas.count

        sign_in(employer)
        assert_difference 'InternshipOfferArea.count', 1 do
          post(
            dashboard_internship_offer_areas_path,
            params: { internship_offer_area: { name: 'Nantes' } }
          )
        end
        area = InternshipOfferArea.last
        assert_equal "Nantes", area.name
        assert_equal employer, area.employer
        assert_equal "User", area.employer_type
        assert_redirected_to dashboard_internship_offer_areas_path
      end

      test 'POST create_area when employer is in a team' do
        employer_1 = create(:employer)
        employer_2 = create(:employer)
        create_team(employer_1, employer_2)

        assert_equal 2, employer_1.internship_offer_areas.count

        sign_in(employer_1)
        assert_difference 'InternshipOfferArea.count', 1 do
          post(
            dashboard_internship_offer_areas_path,
            params: { internship_offer_area: { name: 'Nantes' } }
          )
        end
        area = InternshipOfferArea.last
        assert_equal "Nantes", area.name
        assert_equal employer_1, area.employer
        assert_equal "User", area.employer_type
        assert_redirected_to edit_dashboard_internship_offer_area_path(area)
      end

      test 'without team, employer cannot create an area with a name formerly employed' do
        employer = create(:employer)
        area_name = employer.current_area.name
        sign_in(employer)

        post  dashboard_internship_offer_areas_path(format: :turbo_stream),
              params: { internship_offer_area: { name: area_name } }

        assert_response :success
        assert_select(
          'p.fr-error-text',
          text: "Nom d'espace : ce nom d'espace est déjà utilisé"
        )
      end

      test 'when gathering in a team, formerly identical names are changed' do
        employer_1 = create(:employer, first_name: "Jean", last_name: "Valjean")
        employer_2 = create(:employer, first_name: "Bobby", last_name: "Lapointe")
        formerly_common_name = employer_1.current_area.name
        employer_2.current_area.update(name: formerly_common_name)
        assert_equal formerly_common_name, employer_2.current_area.name
        assert_equal formerly_common_name, employer_1.current_area.name
        assert_equal 2, InternshipOfferArea.all.count
        team_member_invitation = create(:team_member_invitation,
                                        inviter: employer_1,
                                        invitation_email: employer_2.email)

        sign_in(employer_2)
        patch join_dashboard_team_member_invitation_path( id: team_member_invitation.id),
              params: { id: team_member_invitation.id, commit: "Oui" }
        area_name = employer_1.current_area.reload.name
        assert_equal "#{formerly_common_name}-J.V.", area_name
        area_name = employer_2.current_area.reload.name
        assert_equal "#{formerly_common_name}-B.L.", area_name
      end
    end
  end
end
