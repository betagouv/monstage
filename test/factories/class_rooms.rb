# frozen_string_literal: true

FactoryBot.define do
  factory :class_room do
    school
    name { '3e A' }
    school_track { 'troisieme_generale' }
  end
end
