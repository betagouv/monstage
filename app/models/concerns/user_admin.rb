# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern
  BASE_FIELDS = %i[id email first_name last_name].freeze
  DEFAULTS_FIELDS = (BASE_FIELDS + %i[confirmed_at]).freeze

  included do
    rails_admin do
      list do
        fields(*BASE_FIELDS)
        field :school do
          pretty_value do
            object = bindings[:object]
            if object.respond_to?(:school) && object.school.is_a?(School)
              school = bindings[:object].school
              path = bindings[:view].show_path(model_name: school.class.name, id: school.id)
              bindings[:view].content_tag(:a, school.name, href: path)
            end
          end
        end
        field :class_room do
          pretty_value do
            object = bindings[:object]
            if object.respond_to?(:class_room) && object.class_room.is_a?(ClassRoom)
              class_room = bindings[:object].class_room
              bindings[:view].content_tag(:div, class_room.name)
            end
          end
        end
        field :confirmed_at
      end

      edit do
        fields(*DEFAULTS_FIELDS)
      end

      # show do
      #   fields(*UserAdmin::DEFAULTS_FIELDS)
      # end

      show do
        fields(*DEFAULTS_FIELDS)
        field :confirmation_sent_at do
          date_format 'KO'
          strftime_format '%d/%m/%Y'
        end

        field :phone
        field :school do
          visible do
            bindings[:object].respond_to?(:school)
          end
        end

        field :sign_in_count
      end

      export do
        fields(*UserAdmin::DEFAULTS_FIELDS)
        field :role
        field :type
      end
    end
  end
end
