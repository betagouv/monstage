# frozen_string_literal: true

module Users
  class MainTeacher < User
    include UserAdmin
    include ManagedUser

    belongs_to :class_room, optional: true
    has_many :students, through: :class_room

    rails_admin do
      list do
        fields *UserAdmin::DEFAULTS_FIELDS
        field :school do
          pretty_value do
            school = bindings[:object].school
            if school.is_a?(School)
              path = bindings[:view].show_path(model_name: school.class.name, id: school.id)
              bindings[:view].content_tag(:a, school.name, href: path)
            end
          end
        end
      end
    end

    def after_sign_in_path
      return url_helpers.account_path if [school, class_room].any?(&:blank?)

      super
    end

    def custom_dashboard_path
      url_helpers.dashboard_school_class_room_path(school, class_room)
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def custom_dashboard_paths
      [
        url_helpers.dashboard_school_class_room_path(school, class_room)
      ]
    rescue ActionController::UrlGenerationError
      []
    end

    def dashboard_name
      'Ma classe'
    end
  end
end
