# frozen_string_literal: true

# Every type of employer should be able to create a team and an internship offer area
# This module gathers the common methods for all employers_likes.
module Teamable
  extend ActiveSupport::Concern

  included do
    has_many :members_in_team,
              class_name: 'TeamMemberInvitation',
              dependent: :destroy,
              foreign_key: :member_id

    has_many :team_member_invitations,
             dependent: :destroy,
             foreign_key: :inviter_id

    has_many :internship_offer_areas,
             as: :employer,
             class_name: 'InternshipOfferArea',
             foreign_key: 'employer_id'

    has_many :internship_offers,
             through: :internship_offer_areas,
             source: :employer,
             source_type: "User",
             class_name: 'InternshipOffer',
             foreign_key: 'employer_id'

    has_many :kept_internship_offers, -> { merge(InternshipOffer.kept) },
             class_name: 'InternshipOffer', foreign_key: 'employer_id'

    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications
    has_many :organisations  #TODO keep ?
    has_many :tutors #TODO keep ?
    has_many :internship_offer_infos #TODO keep ?

    # scope :internship_offers, lambda do
    #   InternshipOffer.joins(internship_offer_area: :employer)
    #                  .where(internship_offer_areas: { employer: all })
    # end

    def internship_offers
      InternshipOffer.joins(:internship_offer_area)
                     .where(internship_offer_area: {employer_id: team_members_ids})
    end

    # def internship_offer_areas
    #   InternshipOfferArea.where(employer_id: team_members_ids)
    # end

    def internship_agreements
      return super unless team.alive?

      internship_applications = InternshipApplication.where(internship_offer: internship_offers)
      InternshipAgreement.where(internship_application: internship_applications)
    end

    def team
      Team.new(self)
    end

    def team_id
      team.team_owner_id || id
    end

    def team_members_ids
      members = team.team_members.pluck(:member_id)
      members.empty? ? [id] : members
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
  end
end
