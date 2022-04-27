class IdentitiesController < ApplicationController
  def new
    @identity = Identity.new
  end

  def create
    @identity = Identity.new(identity_params)
    if @identity.save
      redirect_to(
        new_user_registration_path(identity_token: @identity.token, as: 'Student', targeted_offer_id: params[:targeted_offer_id]),
        flash: { success: I18n.t('devise.registrations.second_step')}
      )
    else
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
        new_user_registration_path(identity_token: @identity.token, as: 'Student', targeted_offer_id: params[:targeted_offer_id]),
        flash: { success: I18n.t('devise.registrations.second_step')}
      )
    else
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
            :gender,
          )
  end
end
