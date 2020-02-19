# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      configure :confirmed_at, :datetime do
        date_format 'BUGGY'
      end
      configure :confirmed_atmation_sent_at, :datetime do
        date_format 'BUGGY'
      end

      list do
        field :id
        field :email
        field :first_name
        field :last_name
        field :confirmed_at
      end

      edit do
        field :id
        field :email
        field :first_name
        field :last_name
        field :confirmed_at
      end

      show do
        field :id
        field :email
        field :phone
        field :first_name
        field :last_name
        field :school do
          visible do
            bindings[:object].respond_to?(:school)
          end
        end
        field :confirmed_at
        field :confirmation_sent_at
        field :sign_in_count
      end
    end
  end
end
