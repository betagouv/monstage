FactoryBot.define do
  factory :practical_info do
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    siret { FFaker::CompanyFR.siret }
    employer { create(:employer) }
    weekly_lunch_break { '12:00-13:00' }
    weekly_hours { [] }
    daily_hours { [] }
    daily_lunch_break { '12:00-13:00' }
  end
end
