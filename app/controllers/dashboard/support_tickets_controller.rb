# TO DO REMOVE
module Dashboard
  class SupportTicketsController < ApplicationController
    before_action :authenticate_user!

    def new
      @available_weeks ||= Week.selectable_from_now_until_end_of_school_year
      @support_ticket ||= current_user.new_support_ticket
    end

    def create
      authorize! :create_remote_internship_request, SupportTicket
      @support_ticket = current_user.new_support_ticket params: support_ticket_params
      if @support_ticket.valid?
        @support_ticket.send_to_support
        success_message = 'Votre message a bien été envoyé et une association ' \
                          'prendra contact avec vous prochainement'
        redirect_to(current_user.custom_dashboard_path,
                      flash: { success: success_message })
      else
        flash.now[:error] = "Votre message est incomplet : #{@support_ticket.errors.full_messages}"
        @available_weeks ||= Week.selectable_from_now_until_end_of_school_year
        render :new, status: :bad_request
      end
    end

    private

    def support_ticket_params
      params.require(:support_ticket)
            .permit(
              :message,
              :webinar,
              :face_to_face,
              :digital_week,
              :speechers_quantity,
              :business_lines_quantity,
              :paqte,
              :students_quantity,
              :class_rooms_quantity,
              week_ids: []
            )
    end
  end
end
