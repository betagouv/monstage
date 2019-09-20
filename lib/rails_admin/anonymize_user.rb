require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class AnonymizeUser <  RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :link_icon do
          'icon-trash'
        end

        register_instance_option :visible? do
          subject = bindings[:object]
          authorized? && !subject.discarded?
        end

        register_instance_option :controller do
          proc do
            user_email_anonymizing = @object.email.dup
            @object.anonymize
            flash[:notice] = "Anonymization de #{user_email_anonymizing} en cours... Veuillez rafraichir la page"
            redirect_to back_or_index
          end
        end
      end
    end
  end
end
