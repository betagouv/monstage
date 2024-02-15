FactoryBot.define do
  factory :internship_offer_stats do
    internship_offer { nil }
    blocked_weeks_count { 1 }
    total_applications_count { 1 }
    approved_applications_count { 1 }
    total_male_applications_count { 1 }
    view_count { 1 }
    submitted_applications_count { 1 }
    rejected_applications_count { 1 }
    total_male_approved_applications_count { 1 }
    total_female_applications_count { 1 }
    total_female_approved_applications_count { 1 }
    remaining_seats_count { 1 }
    need_update { false }
  end
end
