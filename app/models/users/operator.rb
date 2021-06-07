# frozen_string_literal: true

module Users
  class Operator < User
    belongs_to :operator, foreign_key: :operator_id,
                          class_name: '::Operator'

    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    has_many :internship_applications, through: :internship_offers

    before_create :set_api_token

    rails_admin do
      list do
        fields(*UserAdmin::DEFAULTS_FIELDS)
        field :operator
      end
    end

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def dashboard_name
      'Mes offres'
    end

    private

    def set_api_token
      self.api_token = SecureRandom.uuid
    end
  end
end
