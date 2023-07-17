class InternshipOfferArea < ApplicationRecord
  belongs_to :employer, polymorphic: true
  has_many :users, 
           foreign_key: 'current_area_id',
           class_name: 'User',
           inverse_of: :internship_offer_area
  has_many :internship_offers
  has_many :area_notifications, dependent: :destroy

  validates :name,
            presence: true,
            uniqueness: { scope: :employer_id }
  validates :employer_id, presence: true

  validate :name_uniqueness_in_team
  accepts_nested_attributes_for :area_notifications

  private

  def name_uniqueness_in_team
    employer = User.find_by(id: employer_id)
    if employer.nil?
      errors.add(:employer_id, :invalid)
    elsif employer.internship_offer_areas.pluck(:name).include?(name)
      errors.add(:name, :taken)
    end
  end
end
