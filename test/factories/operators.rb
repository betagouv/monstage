# frozen_string_literal: true

FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "operator-#{n}" }
    logo { 'Logo-telemaque.png' }
    airtable_id { 'abc' }
    airtable_link { 'abc' }
    airtable_table { 'abc' }
  end
end
