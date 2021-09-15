# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :internship_offers
  before_create :set_uuid

  rails_admin do
    list do
      field :name
      field :uuid
    end
    show do
      field :name
      field :uuid
    end
    edit do
      field :name
    end
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end
end
