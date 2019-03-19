FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }
    sequence(:email) {|n| "jean#{n}-claude@dus.fr" }
    password { 'ooooyeahhhh' }
    confirmed_at { Time.now }

    factory :student, class: 'Student', parent: :user do
      type { 'Student' }
      birth_date { Date.new(2005, 1, 1) }
    end

    factory :employer, class: 'Employer', parent: :user do
      type { 'Employer' }
    end
    factory :god, class: 'God', parent: :user do
      type { 'God' }
    end

    factory :school_manager, class: 'SchoolManager', parent: :user do
      sequence(:email) {|n| "jean#{n}-claude@ac-dus.fr" }
      type { 'SchoolManager' }
    end
  end
end
