FactoryBot.define do
  factory :practical_info do
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    employer { create(:employer) }
    weekly_hours { [] }
    daily_hours { 
      {
        'lundi' => ['09:00', '17:00'],
        'mardi' => ['09:00', '17:00'],
        'mercredi' => ['09:00', '17:00'],
        'jeudi' => ['09:00', '17:00'],
        'vendredi' => ['09:00', '17:00']
      }
    }
    lunch_break { '12:00-13:00' }
  end
end
