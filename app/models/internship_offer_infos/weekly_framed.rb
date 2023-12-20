# frozen_string_literal: true

module InternshipOfferInfos
  class WeeklyFramed < InternshipOfferInfo
    # validates :weeks, presence: true
    # has_many :internship_offer_info_weeks, dependent: :destroy,
    #                                        foreign_key: :internship_offer_info_id,
    #                                        inverse_of: :internship_offer_info

    # has_many :weeks, through: :internship_offer_info_weeks
  end
end
