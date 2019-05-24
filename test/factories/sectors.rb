# frozen_string_literal: true

FactoryBot.define do
  factory :sector do
    sequence(:name) { |n| "secteur-#{n}" }
  end
end
