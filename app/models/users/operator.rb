module Users
  class Operator < User
    include InternshipOffersScopes::ByOperator

    belongs_to :operator, foreign_key: :operator_id,
                          class_name: '::Operator'

    has_many :internship_offers, dependent: :destroy,
                                 foreign_key: 'employer_id'

    scope :targeted_internship_offers, -> (user:) {
      query = InternshipOffer.kept
      query = query.merge(by_operator(user: user))
      query
    }

    def custom_dashboard_path
      return url_helpers.dashboard_internship_offers_path
    rescue
      url_helpers.account_path
    end
  end
end
