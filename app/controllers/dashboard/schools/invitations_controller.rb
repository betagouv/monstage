module Dashboard
  module Schools
    class InvitationsController < ApplicationController
      before_action :invitation_params, only: :create
      before_action :set_invitation, only: %i[destroy resend_invitation]

      def index
      end

      def new
        authorize! :create_invitation, Invitation
        @school      = current_user.school
        @invitation  = current_user.invitations.build
      end

      def create
        authorize! :create_invitation, Invitation
        if already_in_staff?(params, current_user)
          redirect_to(
              dashboard_school_users_path(school_id: fetch_school_id),
              alert: "La personne que vous voulez inviter est déjà " \
                     "inscrite ou en cours d'inscription"
          ) and return
        end

        @invitation = current_user.invitations.build(invitation_params)
        @invitation.sent_at = Time.now
        if @invitation.save && invite_staff(invitation: @invitation, from: current_user)
          success_message = "un message d'invitation à " \
                            "#{@invitation.first_name} #{@invitation.last_name} " \
                            "vient d'être envoyé"
          redirect_to dashboard_school_users_path(school_id: fetch_school_id),
                      notice: success_message
        else
          render :new, status: :bad_request
        end
      end

      def destroy
        authorize! :destroy_invitation, Invitation
        if @invitation.destroy
          redirect_to dashboard_school_users_path(school_id: fetch_school_id),
                      notice: 'L\'invitation a bien été supprimée'
        else
          alert_message = "Votre invitation n'a pas pu être supprimée ..."
          redirect_to dashboard_school_users_path(school_id: fetch_school_id),
                      alert: alert_message
        end
      end

      def resend_invitation
        authorize! :create_invitation, Invitation
        invite_staff(invitation: @invitation, from: @invitation.author )
        redirect_to dashboard_school_users_path,
                    notice: 'Votre invitation a été renvoyée'
      end

      def invite_staff(invitation:, from:)
        params = { from: from, invitation: invitation }
        InvitationMailer.staff_invitation(**params).deliver_later
      end

      private

      def invitation_params
        params.require(:invitation)
              .permit(:first_name,
                      :last_name,
                      :email,
                      :role)
      end

      def fetch_school_id
        current_user.school&.id
      end

      def set_invitation
        @invitation = Invitation.find params[:id]
      end

      def already_in_staff?(params, manager)
        staff = ::Users::SchoolManagement.find_by_email(invitation_params[:email])

        staff&.school == manager.school
      end
    end
  end
end
