# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include Phonable

    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # sentry: 1245741475
    # rescued "race condition" on creation : form is submitted twice, and pg fails with uniq constraint
    # 1st request is being created...
    # 2nd twice arrives, checks for existance of first that is not yet commited in PG
    # 1st is commited on PG
    # 2nd try to commit, rails raise ActiveRecord::RecordNotUnique
    rescue_from(ActiveRecord::RecordNotUnique) do |_error|
      redirect_to after_inactive_sign_up_path_for(resource)
    end
    # GET /users/choose_profile
    # def choose_profile
    #
    # end
    def confirmation_standby
      flash.delete(:notice)
      @confirmable_user = User.where(email: params[:email]).first if params[:email].present?
      @confirmable_user ||= nil
    end

    def confirmation_phone_standby
      flash.delete(:notice)
      @confirmable_user = User.where(phone: params[:phone]).first if params[:phone].present?
      @confirmable_user ||= nil
    end

    def resource_class
      UserManager.new.by_params(params: params)
    rescue KeyError
      User
    end

    # GET /resource/sign_up
    def new
      @resource_channel = resource_channel
      options = {}
      options = options.merge(targeted_offer_id: params.dig(:user, :targeted_offer_id)) if params.dig(:user, :targeted_offer_id)

      if UserManager.new.valid?(params: params)
        super do |resource|
          resource.targeted_offer_id ||= params.dig(:user, :targeted_offer_id)
          @current_ability = Ability.new(resource)
        end
      else
        redirect_to users_choose_profile_path(options)
      end
    end

    def resource_channel
      return current_user.channel unless current_user.nil?
      return :email unless params[:as] == 'Student'
    end

    # POST /resource
    def create
      clean_phone_param
      super do |resource|
        resource.targeted_offer_id ||= params.dig(:user, :targeted_offer_id)
        @current_ability = Ability.new(resource)
      end
    end

    def phone_validation
      if fetch_user_by_phone.try(:check_phone_token?, params[:phone_token])
        fetch_user_by_phone.confirm_by_phone!
        message = { success: I18n.t('devise.confirmations.confirmed') }
        redirect_to(
          new_user_session_path(phone: fetch_user_by_phone.phone),
          flash: message
        )
      else
        err_message = { alert: I18n.t('devise.confirmations.unconfirmed') }
        redirect_to(
          users_registrations_phone_standby_path(phone: params[:phone]),
          flash: err_message
        )
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
          accept_terms
          role
          phone
          email
          targeted_offer_id
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
      if resource.phone.present?
        options = { phone: resource.phone }
        options = options.merge({ as: 'Student'}) if resource.student?
        users_registrations_phone_standby_path(options)
      else
        users_registrations_standby_path(email: resource.email)
      end
    end
  end
end
