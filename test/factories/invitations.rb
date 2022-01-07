FactoryBot.define do
  factory :invitation do
    first_name { "Laurent" }
    last_name { 'Mac Fly' }
    sequence(:email) { |n| "jean#{n}-claude@francois.fr" }
    user_id { create(:school_manager).id }
    role { 'main_teacher' }
  end
end
