FactoryBot.define do
  factory :hosting_info do
    employer { create(:employer) }
    weeks { Week.selectable_from_now_until_next_school_year.first(2) }
    weeks_count { 0 }
    max_candidates { 2 }
    max_students_per_group { 1 }
  end
end
