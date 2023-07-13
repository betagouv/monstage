# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern

  DEFAULT_FIELDS      = %i[id email first_name last_name]
  ACCOUNT_FIELDS      = %i[confirmed_at sign_in_count]
  DEFAULT_EDIT_FIELDS = %i[first_name last_name email phone password confirmed_at type discarded_at]
  DEFAULT_SCOPES      = %i[kept discarded]

  included do
    rails_admin do
      weight 1

      list do
        fields(*DEFAULT_FIELDS)
        field :type do
          pretty_value do
            value.constantize.model_name.human
          end
        end
        fields(*ACCOUNT_FIELDS)

        scopes(DEFAULT_SCOPES)
      end

      edit do
        fields(*DEFAULT_EDIT_FIELDS)
      end

      # show do
      #   fields(*UserAdmin::DEFAULT_FIELDS)
      # end

      show do
        fields(*DEFAULT_FIELDS)
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
        fields(*DEFAULT_FIELDS)
        field :role
        field :type
      end
    end
  end
end
