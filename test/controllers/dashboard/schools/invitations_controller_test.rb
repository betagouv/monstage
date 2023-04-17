require 'test_helper'

module Dashboard
  module Schools
    class InvitationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'POST invitation' do
        school_manager = create(:school_manager)
        invitation = {
          first_name: 'Pablo',
          last_name: 'Picasso',
          email: 'pablo@ac-paris.fr',
          user_id: school_manager.id,
          role: 'teacher'
        }

        sign_in(school_manager)
        assert_difference 'Invitation.count' do
          post(
            dashboard_school_invitations_path(school_manager.school.id),
            params: { invitation: invitation }
          )
        end

        assert_equal 'Pablo', Invitation.last.first_name, 'invitation creation failed'
      end

      test 'POST invitation with existing teacher' do
        school_manager = create(:school_manager)
        teacher = create(:teacher, school: school_manager.school)
        invitation = {
          first_name: teacher.first_name,
          last_name: teacher.last_name,
          email: teacher.email,
          user_id: school_manager.id,
          role: 'teacher'
        }

        sign_in(school_manager)
        post(
          dashboard_school_invitations_path(school_manager.school.id),
          params: { invitation: invitation }
        )
        assert_redirected_to dashboard_school_users_path
        assert_equal 0, Invitation.count, 'invitation should not have been successfull'
      end

      test 'POST invitation with existing teacher but from another school' do
        school_manager = create(:school_manager)
        teacher = create(:teacher, school: create(:school, :with_school_manager))
        invitation = {
          first_name: teacher.first_name,
          last_name: teacher.last_name,
          email: teacher.email,
          user_id: school_manager.id,
          role: 'teacher'
        }

        sign_in(school_manager)
        assert_difference 'Invitation.count' do
          post(
            dashboard_school_invitations_path(school_manager.school.id),
            params: { invitation: invitation }
          )
          assert_redirected_to dashboard_school_users_path(school_manager.school)
        end
      end

      test 'DESTROY invitation' do
        school_manager = create(:school_manager)
        invitation = create(:invitation, user_id: school_manager.id)
        school = school_manager.school

        sign_in(school_manager)

        assert_changes -> { Invitation.count }, from: 1, to: 0 do
          path = dashboard_school_invitation_path(school.id, invitation.to_param)
          delete path
          assert_redirected_to dashboard_school_users_path(school.id)
        end

        assert_equal 0, Invitation.count, 'invitation removal failed'
      end

      test 'resend_invitation' do
        school_manager = create(:school_manager)
        invitation = create(:invitation, user_id: school_manager.id)
        school = school_manager.school

        sign_in(school_manager)
        assert_enqueued_emails 1 do
          assert_no_changes -> { Invitation.count } do
            path = dashboard_school_resend_invitation_path(school.id, id: invitation.id)
            get path
            assert_redirected_to dashboard_school_users_path(school.id)
          end
        end
      end
    end
  end
end

