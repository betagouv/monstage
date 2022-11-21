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
      @confirmable_user = ::User.find_by(id: params[:id]) if params[:id].present?
      @confirmable_user ||= nil
    end
    alias confirmation_phone_standby confirmation_standby

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

      :email
    end

    # POST /resource
    def create
      # honey_pot checking
      unless params[:user][:confirmation_email].blank? || EmailWhitelist.where(email: params[:user][:email]).first
        notice = "Votre inscription a bien été prise en compte. " \
                 "Vous recevrez un email de confirmation dans " \
                 "les prochaines minutes."
        redirect_to(root_path, flash: { notice: notice }) and return
      end
      params[:user].delete(:confirmation_email) if params.dig(:user, :confirmation_email)

      # students only
      params[:user] = merge_identity(params) if params.dig(:user, :identity_token)

      # in case of phone number reusing.
      if params && params.dig(:user, :phone) && fetch_user_by_phone && @user
        redirect_to(
          new_user_session_path(phone: fetch_user_by_phone.phone),
          flash: { danger: I18n.t('devise.registrations.reusing_phone_number')}
        ) and return
      end
      # students only
      clean_phone_param
      # employers and school_management only

      super do |resource|
        resource.targeted_offer_id ||= params && params.dig(:user, :targeted_offer_id)
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
          accept_terms
          birth_date
          class_room_id
          confirmation_email
          email
          first_name
          employer_role
          gender
          handicap
          id
          last_name
          operator_id
          phone
          phone_prefix
          phone_suffix
          role
          school_id
          targeted_offer_id
          type
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
      if resource.phone.present? && resource.student?
        options = { id: resource.id }
        options = options.merge({ as: 'Student'}) if resource.student?
        users_registrations_phone_standby_path(options)
      else
        users_registrations_standby_path(id: resource.id)
      end
    end

    def merge_identity(params)
      identity = Identity.find_by_token(params[:user][:identity_token])

      params[:user].merge({
        first_name: identity.first_name,
        last_name: identity.last_name,
        birth_date: identity.birth_date,
        school_id: identity.school_id,
        class_room_id: identity.class_room_id,
        gender: identity.gender
      })
    end
  end
end
