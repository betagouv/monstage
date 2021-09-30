FactoryBot.define do
  factory :internship_offer_info do
    title { "Stage de 3è" }
    description { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eros orci, iaculis ut suscipit non, imperdiet non libero. Proin tristique metus purus, nec porttitor quam iaculis sed. Aenean mattis a urna in vehicula. Morbi leo massa, maximus eu consectetur a, convallis nec purus. Praesent ut erat elit. In eleifend dictum est eget molestie. Donec varius rhoncus neque, sed porttitor tortor aliquet at. Ut imperdiet nulla nisi, eget ultrices libero semper eu.' }
    max_candidates { 1 }
    max_students_per_group { 1 }
    sector { create(:sector) }
    employer { create(:employer) }
    weeks_count { 0 }
    weekly_hours { ['9:00','17:00'] }
    new_daily_hours { {} }

    trait :weekly_internship_offer_info do
      weeks { [Week.first] }
      school_track { :troisieme_generale }
      type { 'InternshipOfferInfos::WeeklyFramed' }
    end
    trait :free_date_internship_offer_info do
      school_track { :troisieme_segpa }
      type { 'InternshipOfferInfos::FreeDate' }
    end

    factory :weekly_internship_offer_info, traits: [:weekly_internship_offer_info],
                                           class: 'InternshipOfferInfos::WeeklyFramed',
                                           parent: :internship_offer_info
    factory :free_date_internship_offer_info, traits: [:free_date_internship_offer_info],
                                      aliases: [:troisieme_segpa_internship_offer_info],
                                      class: 'InternshipOfferInfos::FreeDate',
                                      parent: :internship_offer_info
  end
end
