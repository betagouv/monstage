# frozen_string_literal: true

class Group < ApplicationRecord
  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }
  scope :is_paqte, -> { where(is_paqte: true) }
  scope :group_nature, lambda { |is_public|
    is_public.nil? ? all : where(is_public: is_public)
  }
  has_many :internship_offers
  has_many :ministry_statisticians,
            class_name: 'Users::MinistryStatistician',
            dependent: :destroy,
            foreign_key: 'ministry_id'
  has_many :organisations
  has_many :ministries,
            class_name: 'EmailWhitelists::Ministry',
            dependent: :destroy,
            inverse_of: :group

  rails_admin do
    weight 15
    navigation_label 'Divers'
  end
end
