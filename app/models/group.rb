# frozen_string_literal: true

class Group < ApplicationRecord
  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }
  scope :is_pacte, -> { where(is_pacte: true) }

  scope :group_nature, lambda { |is_public|
    is_public.nil? ? all : where(is_public: is_public)
  }
  has_many :internship_offers
  has_many :organisations
end
