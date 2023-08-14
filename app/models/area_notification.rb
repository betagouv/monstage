class AreaNotification < ApplicationRecord
  belongs_to :user
  belongs_to :internship_offer_area

  validates :user_id,
            uniqueness: { scope: %i[ notify internship_offer_area_id],
                          message: "Les notifications pour cet utilisateur sont" \
                                   " déjà fixées sur cet espace"}

  def presenter
    Presenters::AreaNotification.new(self)
  end

end
