FactoryBot.define do
  factory :internship_offer do
    title { "Stage de 3è" }
    description  { "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eros orci, iaculis ut suscipit non, imperdiet non libero. Proin tristique metus purus, nec porttitor quam iaculis sed. Aenean mattis a urna in vehicula. Morbi leo massa, maximus eu consectetur a, convallis nec purus. Praesent ut erat elit. In eleifend dictum est eget molestie. Donec varius rhoncus neque, sed porttitor tortor aliquet at. Ut imperdiet nulla nisi, eget ultrices libero semper eu." }
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
    coordinates { Coordinates.paris }
    weeks { [ Week.first ] }

  end
end
