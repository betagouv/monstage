# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer_week do
    transient do
      date { Date.today }
      floating_school_year { SchoolYear::Floating.new(date: date) }
      school_year_week {Week.selectable_for_school_year(school_year: floating_school_year).first}
    end

    week { school_year_week }
    internship_offer { create(:weekly_internship_offer, weeks: [school_year_week]) }
  end
end
