require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Kpi <  RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :root? do
          true
        end

        register_instance_option :breadcrumb_parent do
          nil
        end

        register_instance_option :controller do
          proc do
            render @action.template_name, status: 200
          end
        end

        register_instance_option :route_fragment do
          ''
        end

        register_instance_option :link_icon do
          'icon-home'
        end
      end
    end
  end
end
