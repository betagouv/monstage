class IdentitiesController < ApplicationController
  def new
    @identity = Identity.new
  end

  def create
    @identity = Identity.new(identity_params)
    if @identity.save
      redirect_to(
        new_user_registration_path(identity_token: @identity.token, as: 'Student', targeted_offer_id: params[:identity][:targeted_offer_id]),
        flash: { success: I18n.t('devise.registrations.second_step')}
      )
    else
      flash[:error] = 'Erreur lors de la validation des informations'
      render :new, status: :bad_request
    end
  end


  private

  def identity_params
    params.require(:identity)
          .permit(
            :school_id,
            :class_room_id,
            :first_name,
            :last_name,
            :birth_date,
            :gender,
          )
  end
end
