FactoryBot.define do
  factory :tutor do
    employer
    tutor_name { "James Phil" }
    tutor_email { "james@mail.com" }
    tutor_phone { "0102030405" }
    tutor_role { "chef de projet "}
  end
end
