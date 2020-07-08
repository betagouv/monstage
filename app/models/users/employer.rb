# frozen_string_literal: true

module Users
  class Employer < User
    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    has_many :kept_internship_offers, -> { merge(InternshipOffer.kept) },
             source: :internship_offer,
             class_name: 'InternshipOffer'

    # has_many :internship_applications, through: :kept_internship_offers#,
    #                                    # source: :employer#,
    #                                    #source_type: "InternshipApplication"

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    end

    def dashboard_name
      'Mes offres'
    end

    def account_link_name
      'Mon compte'
    end

    def internship_applications
      InternshipApplication.joins(internship_offer_week: :internship_offer)
                           .merge(InternshipOffer.kept)
                           .where("internship_offers.employer_id = #{id}")
                           .where("internship_offers.employer_type = 'Users::Employer'")
    end

    def submitted_internship_applications_count
      InternshipApplication.submitted
                           .joins(:internship_offer)
                           .merge(InternshipOffer.kept)
                           .where("internship_offers.employer_id = #{id}")
                           .count
    end

    def anonymize
      super

      internship_offers.map(&:anonymize)
    end
  end
end
