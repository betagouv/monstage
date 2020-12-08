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

      export do
        field :weeks_count
        field :first_monday
        field :last_monday
      end
    end

    validates :street,
              :city,
              presence: true


    validates :max_candidates, numericality: { only_integer: true,
                                               greater_than: 0,
                                               less_than_or_equal_to: MAX_CANDIDATES_PER_GROUP }
    after_initialize :init
    before_create :reverse_academy_by_zipcode
  end
end
