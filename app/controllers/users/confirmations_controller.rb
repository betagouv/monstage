# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    include Phonable
    def create
      if by_phone?
        if fetch_user_by_phone
          SendSmsJob.perform_later(
            user: fetch_user_by_phone,
            message: "Votre code de validation : #{fetch_user_by_phone.phone_token}"
          )
          redirect_to users_registrations_phone_standby_path(phone: fetch_user_by_phone.phone)
        else
          self.resource = resource_class.new
          self.resource.phone = safe_phone_param
          self.resource.errors.add(:phone, 'Votre numéro de téléphone est inconnu')
          render 'devise/confirmations/new'
        end
        return
      end
      super
    end

    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if confirmed_or_already_confirmed?(resource)
        set_flash_message!(:notice, :confirmed)
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
      end
    end

    protected

    def confirmed_or_already_confirmed?(resource)
      return true if resource.errors.empty?

      email_error = resource.errors.details.dig(:email, 0, :error)
      email_error == :already_confirmed
    end

    # The path used after sign up for inactive accounts.
    def after_confirmation_path_for(_resource_name, resource)
      new_user_session_path(email: resource.email)
    end
  end
end
