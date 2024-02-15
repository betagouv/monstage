# frozen_string_literal: true

# Every type of employer should be able to create a team and an internship offer area
# This module gathers the common methods for all employers_likes.
module Teamable
  extend ActiveSupport::Concern

  included do
    include InternshipOfferAreable

    has_many :team_member_invitations,
             dependent: :destroy,
             foreign_key: :inviter_id

    has_many :internship_offer_areas,
             as: :employer,
             class_name: 'InternshipOfferArea',
             foreign_key: 'employer_id'

    has_one :internship_offer_area,
            as: :employer,
            class_name: 'InternshipOfferArea',
            foreign_key: 'current_area_id'

    has_many :internship_offers,
             through: :internship_offer_areas,
             source: :employer,
             source_type: "User",
             class_name: 'InternshipOffer',
             foreign_key: 'employer_id'

    has_many :kept_internship_offers,
             -> { merge(InternshipOffers::WeeklyFramed.kept) },
             class_name: 'InternshipOffers::WeeklyFramed',
             foreign_key: 'employer_id'

    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications

    def personal_internship_offers
      InternshipOffer.where(employer_id: id)
    end

    def team_internship_offers
      InternshipOffer.where(employer_id: team_members_ids)
    end

    def internship_offers
      team_internship_offers.where(internship_offer_area_id: fetch_current_area_id)
    end

    def anonymize(send_email: true)
      if team.alive?
        move_internship_offers_ownership_to_team
        team.remove_member
      else
        InternshipOffer.where(employer_id: id).each do |offer|
          offer.discard
        end
      end
      super(send_email: send_email)
    end

    def internship_agreements
      return super unless team.alive?

      internship_applications = InternshipApplication.where(internship_offer: internship_offers)
      InternshipAgreement.kept.where(internship_application: internship_applications)
    end

    def internship_offer_ids_by_area(area_id: )
      InternshipOffer.kept
                     .where(employer_id: team_members_ids)
                     .where(internship_offer_area_id: area_id || fetch_current_area_id)
                     .pluck(:id)
    end

    def internship_applications_by_area(area_id: )
      offer_ids = internship_offer_ids_by_area(area_id: area_id)
      return InternshipApplication.none if offer_ids.empty?

      InternshipApplication.where(internship_offer_id: offer_ids)
    end

    def internship_applications_by_area_and_states(area_id:, aasm_state: )
      offer_ids = internship_offer_ids_by_area(area_id: area_id)
      return InternshipApplication.none if offer_ids.empty?

      InternshipApplication.where(internship_offer_id: offer_ids)
                           .where(aasm_state: aasm_state)
    end

    def internship_applications_by_states( aasm_state: )
      offer_ids = team_internship_offers.kept.pluck(:id)
      return InternshipApplication.none if offer_ids.empty?

      InternshipApplication.where(internship_offer_id: offer_ids)
                           .where(aasm_state: aasm_state)
    end

    def team
      Team.new(self)
    end

    def team_id
      team.team_owner_id || id
    end

    def team_members_ids
      members = team.team_members.pluck(:member_id).compact
      members.empty? ? [id] : members
    end

    def db_team_members
      users = []
      team_members_ids.each do |user_id|
        users << User.find_by(id: user_id)
      end
      users.compact
    end

    def pending_invitation_to_a_team
      TeamMemberInvitation.with_pending_invitations.find_by(invitation_email: email)
    end

    def pending_invitations_to_my_team
      TeamMemberInvitation.with_pending_invitations.where(inviter_id: team_id)
    end

    def refused_invitations
      TeamMemberInvitation.refused_invitation.where(inviter_id: team_id)
    end

    # -------------------------------
    private
    # -------------------------------

    def move_internship_offers_ownership_to_team
      if team.team_size == 2
        other_employer_id = team.team_members.pluck(:member_id) - [id]
        personal_internship_offers.update_all(employer_id: other_employer_id)
        team.remove_member
      else # more than 2 members
        team_to_quit = team
        team_to_quit.remove_member
        personal_internship_offers.update_all(
          employer_id: team_to_quit.team_owner_id
        )
      end
    end
  end
end
