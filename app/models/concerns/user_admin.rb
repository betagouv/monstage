# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern
  DEFAULTS_FIELDS = %i[id email first_name last_name confirmed_at].freeze

  included do
    rails_admin do
      list do
        fields *DEFAULTS_FIELDS
      end

      edit do
        fields *DEFAULTS_FIELDS
        field :has_parental_consent do
          visible do
            bindings[:object].is_a?(Users::Student)
          end
        end
      end

      show do
        fields *UserAdmin::DEFAULTS_FIELDS
        field :has_parental_consent do
          visible do
            bindings[:object].is_a?(Users::Student)
          end
        end
      end

      show do
        fields *DEFAULTS_FIELDS
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
    end
  end
end
