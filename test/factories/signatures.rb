FactoryBot.define do
  factory :signature do
    user_id { 0 }
    signatory_ip { FFaker::Internet.ip_v4_address }
    signature_phone_number {"+3306#{FFaker::PhoneNumberFR.mobile_phone_number[4..-1].gsub(' ','')}"}
    signature_date { DateTime.now - 25.days }
    internship_agreement { create(:internship_agreement) }
    signature_image {Rack::Test::UploadedFile.new("test/fixtures/files/signature.png", "image/png") }

    trait :school_manager do
      after(:build) do |signature|
        signature.user_id = signature.internship_agreement.school_manager.id
      end
      signatory_role { Signature::signatory_roles[:school_manager] }
    end

    trait :employer do
      after(:build) do |signature|
        signature.user_id = signature.internship_agreement.employer.id
      end
      signatory_role { Signature::signatory_roles[:employer] }
    end
  end
end
