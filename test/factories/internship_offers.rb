FactoryBot.define do
  factory :internship_offer do
    title { "Stage de 3è" }
    description  { "Un stage incroyable" }
    max_candidates { 1 }
    max_weeks { 1 }
    sector { 'Aérien, Aéronautique et Aéroportuaire' }
    can_be_applied_for { true }
    tutor_name { 'Eric Dubois' }
    tutor_phone { '0123456789' }
    tutor_email { 'eric@dubois.fr' }
    is_public { true }
    employer_street { '1 rue du poulet' }
    employer_zipcode { '75001' }
    employer_city { 'Paris' }
    employer_name { 'Octo' }
    coordinates { { latitude: 48, longitude: 0 }  }
    weeks { [ Week.first ] }
  end
end