FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }
    sequence(:email) {|n| "jean#{n}-claude@dus.fr" }
    password { 'ooooyeahhhh' }

    factory :student, class: 'Student', parent: :user do
      type { 'Student' }
    end
  end
end
