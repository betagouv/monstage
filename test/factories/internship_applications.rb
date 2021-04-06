# frozen_string_literal: true

FactoryBot.define do
  factory :internship_application do
    student { create(:student) }
    motivation { 'Suis hyper motivé' }

    trait :drafted do
      aasm_state { :drafted }
    end

    trait :submitted do
      aasm_state { :submitted }
      submitted_at { 3.days.ago }
    end

    trait :expired do
      aasm_state { :expired }
      submitted_at { 15.days.ago }
      expired_at { 3.days.ago }
    end

    trait :approved do
      aasm_state { :approved }
      submitted_at { 3.days.ago }
      approved_at { 2.days.ago }
    end

    trait :rejected do
      aasm_state { :rejected }
      submitted_at { 3.days.ago }
      rejected_at { 2.days.ago }
    end

    trait :canceled_by_employer do
      aasm_state { :canceled_by_employer }
      submitted_at { 3.days.ago }
      rejected_at { 2.days.ago }
      canceled_at { 2.days.ago }
    end
    trait :canceled_by_student do
      aasm_state { :canceled_by_student }
      submitted_at { 3.days.ago }
      canceled_at { 2.days.ago }
    end

    trait :convention_signed do
      aasm_state { :convention_signed }
      submitted_at { 3.days.ago }
      approved_at { 2.days.ago }
      convention_signed_at { 1.days.ago }
    end

    trait :weekly do
      internship_offer { create(:weekly_internship_offer) }
      before(:create) do |ia|
        # kind of trick
        if ia.internship_offer_week.blank?
          ia.internship_offer_week = create(:internship_offer_week, internship_offer: ia.internship_offer)
        end
      end
    end

    trait :free_date do
      internship_offer { create(:free_date_internship_offer) }
    end


    factory :weekly_internship_application, traits: [:weekly],
                                            parent: :internship_application,
                                            class: 'InternshipApplications::WeeklyFramed'
    factory :free_date_internship_application, traits: [:free_date],
                                               parent: :internship_application,
                                               class: 'InternshipApplications::FreeDate'
  end
end
