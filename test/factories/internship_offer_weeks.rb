# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer_week do
    internship_offer { create(:internship_offer) }
    week { Week.first }
  end
end
