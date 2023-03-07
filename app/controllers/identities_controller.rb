class IdentitiesController < ApplicationController
  def new
    @identity = Identity.new
  end

  def create
    @identity = Identity.new(identity_params)
    parameters = {identity_token: @identity.token, as: 'Student'}
    parameters.merge!({targeted_offer_id: params[:identity][:targeted_offer_id]}) if params[:identity][:targeted_offer_id].present?
    flash = { success: I18n.t('devise.registrations.second_step') }

    if @identity.save
      redirect_to new_user_registration_path(**parameters), flash: flash
    else
      flash[:error] = 'Erreur lors de la validation des informations'
      render :new
    end
  end

  def edit
    @identity = Identity.find_by_token(params[:id])
  end

  def update
    @identity = Identity.find_by_token(params[:identity][:identity_token])
    if @identity.update(identity_params)
      redirect_to(
        new_user_registration_path(identity_token: @identity.token, as: 'Student', targeted_offer_id: params[:identity][:targeted_offer_id]),
        flash: { success: I18n.t('devise.registrations.second_step') }
      )
    else
      flash[:error] = 'Erreur lors de la modification'
      render :edit
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
            :gender
          )
  end
end
