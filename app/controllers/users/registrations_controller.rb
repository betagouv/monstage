# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /users/choose_profile
    # def choose_profile
    #
    # end
    def confirmation_standby
      flash.delete(:notice)
      @confirmable_user = User.where(email: params[:email]).first if params[:email].present?
      @confirmable_user ||= nil
    end

    def resource_class
      UserManager.new.by_params(params: params)
    rescue KeyError => e
      User
    end

    # GET /resource/sign_up
    def new
      if UserManager.new.valid?(params: params)
        super do |resource|
          @current_ability = Ability.new(resource)
        end
      else
        redirect_to users_choose_profile_path
      end
    end

    # POST /resource
    def create
      super do |resource|
        @current_ability = Ability.new(resource)
      end
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(
        :sign_up,
        keys: %i[
          type
          first_name
          last_name
          birth_date
          gender
          school_id
          class_room_id
          operator_id
          handicap
        ]
      )
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(resource)
      users_registrations_standby_path(email: resource.email)
    end
  end
end
