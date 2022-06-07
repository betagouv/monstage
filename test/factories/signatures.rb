FactoryBot.define do
  factory :signature do
    signatory_ip { FFaker::Internet.ip_v4_address }
    signature_date { DateTime.now - 25.days }
    signatory_role { Signature::signatory_roles[:employer] }
    internship_agreement { create(:internship_agreement) }

    trait :employer_signature do
      signatory_role { Signature::signatory_roles[:employer] }
    end

    trait :school_manager_signature do
      signatory_role { Signature::signatory_roles[:school_manager] }
    end
  end
end
