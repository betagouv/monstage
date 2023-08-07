class InternshipOfferArea < ApplicationRecord
  belongs_to :employer, polymorphic: true
  has_many :users,
           foreign_key: 'current_area_id',
           class_name: 'User',
           inverse_of: :internship_offer_area
  has_many :internship_offers
  has_many :area_notifications, dependent: :destroy

  validates :employer_id, :name, presence: true

  validate :name_uniqueness_in_team

  def team_sibling_areas
    return InternshipOfferArea.none if employer.team.not_exists?

    employer.internship_offer_areas.where.not(id: id)
  end

  def single_human_in_charge?
    return true if employer.team.not_exists?

    AreaNotification.where(user_id: employer.team_members_ids)
                    .where(notify: true)
                    .where(internship_offer_area_id: id)
                    .to_a
                    .count <= 1
  end

  def people_in_charge
    return [] if employer.team.not_exists?

    User.where(id: AreaNotification.where(user_id: employer.team_members_ids)
                                   .where(notify: true)
                                   .where(internship_offer_area_id: id))
  end

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
