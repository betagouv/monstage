# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    is_public { false }
    name { 'MyString' }
  end
end
