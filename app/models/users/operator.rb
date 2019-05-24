# frozen_string_literal: true

module Users
  class Operator < User
    include InternshipOffersScopes::ByOperator

    belongs_to :operator, foreign_key: :operator_id,
                          class_name: '::Operator'

    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    scope :targeted_internship_offers, lambda { |user:|
      mines_and_sumbmitted_to_operator(user: user)
    }

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    rescue StandardError
      url_helpers.account_path
    end
  end
end
