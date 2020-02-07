# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer do
    sequence(:title) { |n| "Stage de 3è - #{n}" }
    description { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eros orci, iaculis ut suscipit non, imperdiet non libero. Proin tristique metus purus, nec porttitor quam iaculis sed. Aenean mattis a urna in vehicula. Morbi leo massa, maximus eu consectetur a, convallis nec purus. Praesent ut erat elit. In eleifend dictum est eget molestie. Donec varius rhoncus neque, sed porttitor tortor aliquet at. Ut imperdiet nulla nisi, eget ultrices libero semper eu.' }
    max_candidates { 1 }
    blocked_weeks_count { 0 }
    sector { create(:sector) }
    tutor_name { 'Eric Dubois' }
    tutor_phone { '0123456789' }
    tutor_email { 'eric@dubois.fr' }
    is_public { true }
    group { create(:group, is_public: true) }
    employer_description { 'on envoie du parpaing' }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    employer_name { 'Octo' }
    coordinates { Coordinates.paris }
    weeks { [Week.first] }
    employer { create(:employer) }
  end

  factory :api_internship_offer, class: Api::InternshipOffer do
    sequence(:title) { |n| "Stage de 3è - #{n}" }
    description { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eros orci, iaculis ut suscipit non, imperdiet non libero. Proin tristique metus purus, nec porttitor quam iaculis sed. Aenean mattis a urna in vehicula. Morbi leo massa, maximus eu consectetur a, convallis nec purus. Praesent ut erat elit. In eleifend dictum est eget molestie. Donec varius rhoncus neque, sed porttitor tortor aliquet at. Ut imperdiet nulla nisi, eget ultrices libero semper eu.' }
    sector { create(:sector) }
    employer_description { 'on envoie du parpaing' }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    employer_name { 'Octo' }
    coordinates { Coordinates.paris }
    weeks { [Week.first] }
    sequence(:remote_id) { |n| n }
    employer { create(:user_operator) }
    permalink { 'https://google.fr' }
  end

  trait :discarded do
    discarded_at { Time.now }
  end

end
