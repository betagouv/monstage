module Dashboard
  module InternshipOfferAreas
    class AreaNotificationsController < ApplicationController

      before_action :authenticate_user!
      before_action :fetch_area_notification, only: %i[edit update flip]

      def index
      end

      def edit
      end

      def flip
        can? :manage_abilities, AreaNotification
        parameters = flip_infos(team_flip: params[:team_flip] || false)
        if current_user.team.alive? && 
            (!current_user.current_area.single_human_in_charge? || !@area_notification.notify)
          @area_notification.update(notify: !@area_notification.notify)
          options = { partial: parameters[:path],
                      locals: { area_notification: @area_notification}}

          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace(parameters[:replace_id], **options)
            end
            format.html do
              destination = edit_dashboard_internship_offer_area_path(@internship_offer_area)
              redirect_to destination, notice: 'Modification du nom d\'espace opérée'
            end
          end
        elsif current_user.team.alive?
          respond_to do |format|
            @internship_offer_area.errors.add(:base, :only_one_left)
            options = { partial: parameters[:path],
                        locals: { area_notification: @area_notification}}
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace(parameters[:replace_id], options)
            end
            format.html do
              destination = edit_dashboard_internship_offer_area_path(@internship_offer_area)
              redirect_to destination, alert: 'Au moins un utilisateur doit recevoir les notifications.'
            end
          end
        else
          redirect_to edit_dashboard_internship_offer_area_path(@internship_offer_area)
        end
      rescue ActiveRecord::RecordInvalid
        redirect_to edit_dashboard_internship_offer_area_path(@internship_offer_area), alert:'Erreur X605'
      end

      def update
      end

      private

      def area_notification_params
        params.require(:area_notification)
              .permit(:user_id, :internship_offer_area_id, :notify)
      end

      def fetch_area_notification
        @area_notification = AreaNotification.find(params[:id])
        @internship_offer_area = @area_notification.internship_offer_area
      end

      def flip_infos(team_flip: false)
        if team_flip
          { path: 'dashboard/internship_offer_areas/area_notifications/toggle',
            replace_id: "area_notification_#{@area_notification.id}"
          }
        else
          { path: 'dashboard/internship_offer_areas/area_notifications/flip_notification',
            replace_id: "flip_notification"
          }
        end
      end
    end
  end
end