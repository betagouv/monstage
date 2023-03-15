# frozen_string_literal: true

FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "operator-#{n}" }
    logo { 'Logo-jobirl.jpg' }
    api_full_access { false }
    target_count { 0 }
    realized_count { { 
      '2022' => {
        'total': '10',
        'onsite': '5',
        'online': '3',
        'hybrid': '2',
        'worshop': '1',
        'private': '8',
        'public': '2' 
      } 
    } }
  end
end
