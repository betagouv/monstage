class Partner < ApplicationRecord
  validates :name, presence: true

  rails_admin do
    list do
      field :name
      field :target_count
    end
    show do
      field :name
      field :target_count
    end
    edit do
      field :name
      field :target_count
    end
  end
end
