# frozen_string_literal: true

class Operator < ApplicationRecord

  has_many :operators, class_name: 'Users::Operator'
  has_many :internship_offers, through: :operators

  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :name
      field :target_count
    end
    show do
      field :name
      field :target_count
      field :logo
      field :website
    end
    edit do
      field :name
      field :target_count
      field :logo
      field :website
    end
  end
end
