module Dashboard
  class InternshipOfferAreasController < ApplicationController
    before_action :authenticate_user!, only: %i[create edit update destroy new filter_by_area]
    before_action :set_internship_offer_area, only: %i[show edit update destroy]

    def index
      @internship_offer_areas = current_user.internship_offer_areas
    end

    def new
      @internship_offer_area = current_user.internship_offer_areas.build
    end

    def edit
    end

    def create
      @internship_offer_area = current_user.internship_offer_areas.build(internship_offer_area_params)
      if @internship_offer_area.save
        current_user.current_area_id_memorize(@internship_offer_area.id)
        set_areas_notifications(@internship_offer_area)
        respond_to do |format|
          format.turbo_stream do
            path = 'dashboard/internship_offer_areas/edit_areas_modal_dialog'
            render turbo_stream:
              turbo_stream.replace("fr-modal-add-space-dialog",
                                    partial: path,
                                    locals: { current_user: current_user,
                                              internship_offer_area: @internship_offer_area })
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            path = 'dashboard/internship_offer_areas/areas_modal_dialog'
            error_message = @internship_offer_area.errors.full_messages
            render turbo_stream:
              turbo_stream.replace("fr-modal-add-space-dialog",
                                    partial: path,
                                    error_message: error_message,
                                    locals: { current_user: current_user,
                                              internship_offer_area: @internship_offer_area })
          end
        end
      end
    end

    def filter_by_area
      current_area_id_memorize(params[:id])
      redirect_to dashboard_candidatures_path
    end

    def update
    end

    def destroy
      authorize! :destroy, @internship_offer_area
      message = 'Espace supprimé avec succès.'
      redirect_to dashboard_internship_offer_areas_path, flash: { success: message }
    rescue ActiveRecord::RecordInvalid
      render :new, status: :bad_request
    end

    private

    def set_areas_notifications(area)
      current_user.team_members_ids do |user_id|
        AreaNotification.create!(
          user_id: user_id,
          area_id: area.id,
          notify: true)
      end
    end

    def internship_offer_area_params
      params.require(:internship_offer_area).permit(:area_id, :name)
    end

    def set_internship_offer_area
      @internship_offer_area = InternshipOfferArea.find(params[:id])
    end
  end
end
