FactoryBot.define do
  factory :team_member_invitation do
    inviter_id{ create(:employer).id }
    invitation_email { FFaker::Internet.email }
    aasm_state {:pending_invitation}
    member_id { nil }

    trait :accepted_invitation do
      aasm_state { :accepted_invitation }
      member_id { create(:employer).id }

    end

    trait :refused_invitation do
      aasm_state { :refused_invitation }
      refused_invitation_at { Time.now }
    end
  end
end
