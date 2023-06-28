FactoryBot.define do
  factory :team_member do
    inviter{ create(:employer) }
    invitation_email { FFaker::Internet.email }
    aasm_state {:pending_invitation}

    trait :accepted_invitation do
      aasm_state { :accepted_invitation }
    end

    trait :refused_invitation do
      aasm_state { :refused_invitation }
      refused_invitation_at { Time.now }
    end
  end
end
