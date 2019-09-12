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
        field :first_name
        field :last_name
      end
    end
  end
end
