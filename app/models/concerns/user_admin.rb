module UserAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :id
        field :email
        field :first_name
        field :last_name
      end

      edit do
        field :id
        field :email
        field :first_name
        field :last_name
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
