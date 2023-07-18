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
      @internship_offer_areas = current_user.internship_offer_areas
    end

    def create
      parameters = internship_offer_area_params.merge(employer_type: 'User')
      @internship_offer_area = current_user.internship_offer_areas.build(parameters)
      if @internship_offer_area.save
        current_user.current_area_id_memorize(@internship_offer_area.id)
        if current_user.team.alive?
          set_areas_notifications(@internship_offer_area)
          redirect_to edit_dashboard_internship_offer_area_path(@internship_offer_area),
                      flash: { success: 'Espace créé avec succès.' }
        else
          redirect_to dashboard_internship_offers_path,
                      flash: { success: 'Espace créé avec succès.' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            path = 'dashboard/internship_offer_areas/areas_modal_dialog'
            render turbo_stream:
              turbo_stream.replace("fr-modal-add-space-dialog",
                                    partial: path,
                                    locals: { current_user: current_user,
                                              internship_offer_area: @internship_offer_area })
          end
        end
      end
    end

    def filter_by_area
      current_user.current_area_id_memorize(params[:id])
      redirect_to dashboard_candidatures_path
    end

    def update
      if @internship_offer_area.update(internship_offer_area_params)
        redirect_to dashboard_internship_offers_path,
                    notice: "Modification du nom d'espace opérée"
      else
        respond_to do |format|
          format.turbo_stream do
            path = 'dashboard/internship_offer_areas/edit_areas_modal_dialog'
            render turbo_stream:
              turbo_stream.replace("fr-modal-edit-space-dialog",
                                    partial: path,
                                    locals: { current_user: current_user,
                                              internship_offer_area: @internship_offer_area })
          end
        end
      end
    end

    def destroy
      authorize! :destroy, @internship_offer_area
      move_internship_offers_to_another_area
      message = 'Espace supprimé avec succès.'
      @internship_offer_area.destroy
      redirect_to dashboard_internship_offer_areas_path, flash: { success: message }
    rescue ActiveRecord::RecordInvalid
      render :new, status: :bad_request
    end

    private

    def move_internship_offers_to_another_area
      target_area = current_user.internship_offer_areas
                                .reject { |area| area == @internship_offer_area }
                                .order(created_at: :asc)
                                .first
      @internship_offer_area.internship_offers.each do |offer|
        offer.update!(internship_offer_area: target_area)
      end
      @internship_offer_area.destroy!
    end

    def set_areas_notifications(area)
      current_user.team_members_ids do |user_id|
        AreaNotification.create!(
          user_id: user_id,
          area_id: area.id,
          notify: true
        )
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
