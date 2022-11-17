# frozen_string_literal: true

FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "operator-#{n}" }
    logo { 'Logo-telemaque.png' }
    airtable_id { 'abc' }
    airtable_link { 'abc' }
    airtable_table { 'abc' }
    airtable_app_id { 'abc' }
    api_full_access { false }
  end
end
