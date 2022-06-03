FactoryBot.define do
  factory :signature do
    ip_student { "10.101.12.13" }
    ip_employer { "103.10.12.14" }
    ip_school_manager { "20.101.128.135" }
    signature_date_employer { Datetime.now - 25.days }
    signature_date_school_manager { Datetime.now - 22.days }
    signature_date_student { Datetime.now - 21.days }
    internship_agreement
  end
end
