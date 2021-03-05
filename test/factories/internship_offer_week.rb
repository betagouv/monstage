# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer_week do
    internship_offer { create(:weekly_internship_offer, weeks: [Week.first]) }
    week { Week.first }
  end
end
