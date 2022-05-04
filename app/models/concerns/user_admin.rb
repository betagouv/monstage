# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern
  BASE_FIELDS = %i[id email first_name last_name].freeze
  DEFAULTS_FIELDS = (BASE_FIELDS + %i[confirmed_at]).freeze

  included do
    rails_admin do
      list do
        fields(*BASE_FIELDS)
        field :type do
          pretty_value do
            value.constantize.model_name.human
          end
        end
        field :confirmed_at
        field :sign_in_count

        scopes [:kept, :discarded]
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
