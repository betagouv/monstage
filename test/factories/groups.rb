FactoryBot.define do
  factory :group do
    is_public { false }
    name { 'MyString' }
    is_pacte { false }
  end
end
