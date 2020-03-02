# frozen_string_literal: true

module Users
  class Other < User
    include UserAdmin
    include ManagedUser

    rails_admin do
      list do
        fields *UserAdmin::DEFAULTS_FIELDS
        field :school do
          pretty_value do
            school = bindings[:object].school
            if school.is_a?(School)
              path = bindings[:view].show_path(model_name: school.class.name, id: school.id)
              bindings[:view].content_tag(:a, school.name, href: path)
            else
              nil
            end
          end
        end
      end
    end

    def custom_dashboard_path
      url_helpers.dashboard_school_class_rooms_path(school)
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def dashboard_name
      'Mon Collège'
    end
  end
end
