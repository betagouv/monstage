FactoryBot.define do
  factory :signature do
    signatory_ip { FFaker::Internet.ip_v4_address }
    signature_phone_number {"+3306#{FFaker::PhoneNumberFR.mobile_phone_number[4..-1].gsub(' ','')}"}
    signature_date { DateTime.now - 25.days }
    signatory_role { Signature::signatory_roles[:employer] }
    internship_agreement { create(:internship_agreement) }
    handwrite_signature { File.read( Rails.root.join('test', 'fixtures', 'files', 'signature.json')).to_json}
    trait :employer_signature do
      signatory_role { Signature::signatory_roles[:employer] }
    end

    trait :school_manager_signature do
      signatory_role { Signature::signatory_roles[:school_manager] }
    end
  end
end
