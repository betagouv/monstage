FactoryBot.define do
  factory :hosting_info do
    employer { create(:employer) }
    weeks { Week.first(2) }
    weeks_count { 0 }
    max_candidates { 2 }
    max_students_per_group { 1 }
  end
end
