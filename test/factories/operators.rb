FactoryBot.define do
  factory :operator do
    sequence(:name) {|n| "operator-#{n}" }
  end
end
