# frozen_string_literal: true

FactoryBot.define do
  factory :class_room do
    school
    name { '3e A' }
    school_track { 'troisieme_generale' }
  end

  trait :troisieme_generale do
    school_track { 'troisieme_generale' }
  end

  trait :troisieme_segpa do
    school_track { 'troisieme_segpa' }
  end

  trait :troisieme_prepa_metiers do
    school_track { 'troisieme_prepa_metiers' }
  end
end
