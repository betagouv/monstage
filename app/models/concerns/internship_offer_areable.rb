module InternshipOfferAreable
  extend ActiveSupport::Concern

  included do
    has_many :area_notifications, dependent: :destroy
    belongs_to :current_area,
               class_name: 'InternshipOfferArea',
               foreign_key: 'current_area_id',
               optional: true

    def create_default_internship_offer_area
      return if internship_offer_areas.any?

      initializing_current_area('Mon espace')
    end
    
    def internship_offer_areas
      super if team.not_exists?

      InternshipOfferArea.where(employer_id: team_members_ids)
    end

    def team_areas
      internship_offer_areas.where(employer_id: team_members_ids)
    end

    def current_area_id_memorize(id)
      update(current_area_id:  id)
    end

    def fetch_current_area_id
      current_area_id.presence || latest_area_id
    end

    def fetch_current_area_notification
      AreaNotification.find_by(
        user_id: id,
        internship_offer_area_id: fetch_current_area_id
      )
    end

    # ------------  private ------------
    private
    # ----------------------------------

    def latest_area_id
      internship_offer_areas.order(updated_at: :desc).first.id
    end
  end
end