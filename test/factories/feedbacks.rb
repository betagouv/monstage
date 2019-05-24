# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    email { 'martin@gmail.com' }
    comment { 'MyText' }
  end
end
