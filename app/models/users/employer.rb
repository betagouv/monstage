# frozen_string_literal: true

module Users
  class Employer < User
    include EmployerAdmin
    include Signatorable


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
      url_helpers.dashboard_internship_agreements_path
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

    def signatory_role
      Signature.signatory_roles[:employer]
    end

    def already_signed?(internship_agreement_id:)
      internship_agreement = InternshipAgreement.joins(:signatures)
                                                .where(id: internship_agreement_id)
                                                .where(signatures: {signatory_role: signatory_role})
      internship_agreement.any? &&
        internship_agreement.first.internship_offer.employer_id == id
    end

    def presenter
      Presenters::Employer.new(self)
    end
  end
end
