module Dashboard
  module Schools
    class SupportTicketsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_school

      def new
        @support_ticket = SupportTicket.new
      end

      def create
        authorize! :create_remote_internship_request, @school
        @support_ticket = SupportTicket.new(support_ticket_params)
        if @support_ticket.valid?
          ticket_creation_result = create_ticket(params: support_ticket_params)
          if ticket_creation_result[:success]
            redirect_to(dashboard_school_class_rooms_path(@school),
                        flash: { success: "Votre message a bien été envoyé" })
          else
            flash.now[:error] = "Votre message n'a pas pu être envoyé"
            render :new
          end
        else
          flash.now[:error] = "Votre message est incomplet : #{@support_ticket.errors.full_messages}"
          render :new
        end
      rescue SystemCallError => e
        error_message = "Une erreur s'est produite et votre message n'a pas pu être envoyé !"
        Rails.logger.error "Zammad error in support_tickets controller : #{e}"

        redirect_to(dashboard_school_class_rooms_path(@school),
                    flash: { alert: error_message })
      end

      private

      def create_ticket(params:)
        zammad_service = Services::ZammadTicket.new
        existing_customer = zammad_service.lookup_user(params: params)
        zammad_service.create_user(params: params) if existing_customer.empty?
        ticket = zammad_service.create_ticket(params: params)
        {success: true}
      end

      def support_ticket_params
        params.require(:support_ticket)
              .permit(
                :first_name,
                :last_name,
                :email,
                :message,
                :webinar,
                :face_to_face,
                :subject,
                :school_id
              )
      end

      def find_school
        @school = School.find_by(id: params[:school_id])
      end
    end
  end
end