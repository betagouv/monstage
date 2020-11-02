FactoryBot.define do
  factory :internship_agreement do
    internship_application { create :weekly_internship_application }
    # aasm_state { :drafted }
    start_date { internship_application.internship_offer_week.week.week_date - 6.weeks }
    end_date { internship_application.internship_offer_week.week.week_date - 4.weeks }
  end
end
