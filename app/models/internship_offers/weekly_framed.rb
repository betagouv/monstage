# frozen_string_literal: true

module InternshipOffers
  class WeeklyFramed < InternshipOffer
    include WeeklyFramable
    include ActiveAdminable
    include OfferWeeklyFramable

    validates :is_public, inclusion: { in: [true, false] }
    validate :validate_group_is_public?, if: :is_public?
    validate :validate_group_is_not_public?, unless: :is_public?
    validates :street,
              :city,
              :tutor_name,
              :tutor_phone,
              :tutor_email,
              presence: true

   
    before_create :reverse_academy_by_zipcode
  end
end
