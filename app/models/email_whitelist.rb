class EmailWhitelist < ApplicationRecord
  validates :email, format: { with: Devise.email_regexp }, on: :create

  rails_admin do
    list do
      field :id
      field :email
      field :zipcode
    end
    show do
      field :id
      field :email
      field :zipcode
    end
    edit do
      field :email
      field :zipcode
    end
  end
end
