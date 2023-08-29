# frozen_string_literal: true

class Group < ApplicationRecord
  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }
  scope :is_paqte, -> { where(is_paqte: true) }
  scope :group_nature, lambda { |is_public|
    is_public.nil? ? all : where(is_public: is_public)
  }
  has_many :internship_offers
  has_many :organisations
  has_many :ministry_groups
  has_many :ministries,
            class_name: 'EmailWhitelists::Ministry',
            foreign_key: 'email_whitelist_id',
            through: :ministry_groups,
            dependent: :destroy,
            inverse_of: :groups
  
  has_many :user_groups
  has_many :users, through: :user_groups, dependent: :destroy, inverse_of: :groups

  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :id
      field :name
      field :is_public
      field :is_paqte
    end

  end
end
