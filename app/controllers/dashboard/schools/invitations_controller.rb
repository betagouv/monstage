module Dashboard
  module Schools
    class InvitationsController < ApplicationController
      before_action :invitation_params, only: :create
      before_action :set_invitation, only: %i[destroy resend_invitation]

      def new
      end

      def create
        redirect_to(
            dashboard_school_users_path,
            flash: { alert: "La personne que vous voulez inviter est déjà " \
                            "inscrite ou en cours d'inscription"}
        ) and return if already_in_staff?(params, current_user)

        @invitation = current_user.invitations.build(invitation_params)
        @invitation.sent_at = Time.now
        if @invitation.save && invite_staff(invitation: @invitation, from: current_user)
          success_message = "un message d'invitation à " \
                            "#{@invitation.first_name} #{@invitation.last_name} " \
                            "vient d'être envoyé"
          redirect_to(
            dashboard_school_users_path,
            flash: { success: success_message }
          )
        else
          redirect_to(
            dashboard_school_users_path,
            flash: { alert: "votre invitation n'a pas pu être envoyée"}
          )
        end
      end

      def index
      end

      def destroy
        if @invitation.destroy
          success_message = 'L\'invitation a bien été supprimée'
          redirect_to dashboard_school_users_path,
                      flash: { success: success_message }
        else
          alert_message = "Votre invitation n'a pas pu être supprimée..."
          redirect_to dashboard_school_users_path,
                      flash: { alert: alert_message }
        end
      end

      def resend_invitation
        invite_staff(invitation: @invitation, from: @invitation.school_manager )
        redirect_to dashboard_school_users_path,
                    flash: { success: 'Votre invitation a été renvoyée' }
      end

      def invite_staff(invitation:, from:)
        params = { from: from, invitation: invitation }
        InvitationMailer.staff_invitation(params).deliver_later
        true
      end

      private

      def invitation_params
        params.require(:invitations)
              .permit(:first_name,
                      :last_name,
                      :email,
                      :role)
      end

      def set_invitation
        @invitation = Invitation.find params[:id]
      end

      def already_in_staff?(params, manager)
        staff = Users::SchoolManagement.find_by_email(invitation_params[:email])
        return false if staff.nil?

        staff&.school == manager.school
      end
    end
  end
end
