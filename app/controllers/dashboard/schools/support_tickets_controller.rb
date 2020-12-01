module Dashboard
  module Schools
    class SupportTicketsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_school

      def new
        @available_weeks ||= Week.selectable_from_now_until_end_of_school_year
        @support_ticket ||= SupportTicket.new
      end

      def create
        authorize! :create_remote_internship_request, @school
        @support_ticket = SupportTicket.new(support_ticket_params)
        @support_ticket.assign_attributes(user_id: current_user.id)
        if @support_ticket.valid?
          job_params = @support_ticket.as_json.symbolize_keys
          CreateSupportTicketJob.perform_later(params: job_params)
          success_message = 'Votre message a bien été envoyé et une association ' \
                            'prendra contact avec vous prochainement'
          redirect_to(dashboard_school_class_rooms_path(@school),
                        flash: { success: success_message })
        else
          flash.now[:error] = "Votre message est incomplet : #{@support_ticket.errors.full_messages}"
          @available_weeks ||= Week.selectable_from_now_until_end_of_school_year
          render :new
        end
      rescue StandardError => e
        Rails.logger.error "Zammad error in support_tickets controller : #{e}"
        error_message = "Une erreur s'est produite et votre message n'a pas pu être envoyé !"
        redirect_to(dashboard_school_class_rooms_path(@school),
                    flash: { alert: error_message })
      end

      private

      def support_ticket_params
        params.require(:support_ticket)
              .permit(
                :message,
                :webinar,
                :face_to_face,
                :digital_week,
                :subject,
                :school_id,
                :students_quantity,
                :class_rooms_quantity,
                week_ids: []
              )
      end

      def find_school
        @school = School.find_by(id: params[:school_id])
      end
    end
  end
end