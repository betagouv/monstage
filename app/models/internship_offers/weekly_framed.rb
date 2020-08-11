# frozen_string_literal: true

module InternshipOffers
  class WeeklyFramed < InternshipOffer
    include WeeklyFramable
    include ActiveAdminable
    # ActiveAdmin index specifics
    rails_admin do
      list do
        scopes [:not_from_api]
        field :title
        field :zipcode
        field :employer_name
        field :group
        field :is_public
        field :department
        field :created_at
      end
    end

    validates :street,
              :city,
              :tutor_name,
              :tutor_phone,
              :tutor_email,
              presence: true

    validates :is_public, inclusion: { in: [true, false] }
    validate :validate_group_is_public?, if: :is_public?
    validate :validate_group_is_not_public?, unless: :is_public?

    validates :max_candidates, numericality: { only_integer: true,
                                               greater_than: 0,
                                               less_than_or_equal_to: MAX_CANDIDATES_PER_GROUP }
    after_initialize :init
    before_create :reverse_academy_by_zipcode

    attr_reader :with_operator

    def validate_group_is_public?
      return if group.nil?

      errors.add(:group, 'Veuillez choisir une institution de tutelle') unless group.is_public?
    end

    def validate_group_is_not_public?
      return if group.nil?

      errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
    end
  end
end
