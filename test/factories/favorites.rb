# frozen_string_literal: true

FactoryBot.define do
  factory :favorite do
    user { create(:student_with_class_room_3e) }
    internship_offer { create(:weekly_internship_offer) }
  end
end
