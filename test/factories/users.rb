FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }
    sequence(:email) {|n| "jean#{n}-claude@dus.fr" }
    password { 'ooooyeahhhh' }

    factory :student, class: 'Student', parent: :user do
      type { 'Student' }
    end

    factory :school_manager, class: 'SchoolManager', parent: :user do
      sequence(:email) {|n| "jean#{n}-claude@ac-dus.fr" }
      type { 'SchoolManager' }
    end
  end
end
