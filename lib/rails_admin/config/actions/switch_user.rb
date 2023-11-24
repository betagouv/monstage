require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class SwitchUser <  Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          authorized? && bindings[:object].is_a?(User)
        end

        register_instance_option :member do
          true
        end

        register_instance_option :link_icon do
          'fas fa-eye'
        end

        # You may or may not want pjax for your action
        register_instance_option :pjax? do
          false
        end

        register_instance_option :controller do
          proc do
            cookies.signed[Rails.application.credentials.dig(:cookie_switch_back)] = current_user.id
            sign_in(@object, scope: :user)
            redirect_to @object.after_sign_in_path
          end
        end
      end
    end
  end
end
