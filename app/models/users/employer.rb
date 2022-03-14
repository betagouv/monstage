# frozen_string_literal: true

module Users
  class Employer < User
    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    has_many :kept_internship_offers, -> { merge(InternshipOffer.kept) },
             class_name: 'InternshipOffer'

    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications 

    has_many :organisations
    has_many :tutors
    has_many :internship_offer_infos

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    end

    def custom_agreements_path
      url_helpers.dashboard_internship_applications_path
    end

    def dashboard_name
      'Mon tableau de bord'
    end

    def account_link_name
      'Mon compte'
    end

    def new_support_ticket(params: {})
      SupportTickets::Employer.new(params.merge(user_id: self.id))
    end

    def employer? ; true end

    def anonymize(send_email: true)
      super

      internship_offers.map(&:anonymize)
    end
  end
end
