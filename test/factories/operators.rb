# frozen_string_literal: true

FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "operator-#{n}" }
    logo { 'Logo-telemaque.png' }
  end
end
