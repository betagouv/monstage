# generated with: rails g model AirTableRecord school_name:text organisation_name:text department_name:text sector_name:text is_public:boolean nb_spot_available:integer nb_spot_used:integer nb_spot_male:integer nb_spot_female:integer school_track:text internship_offer_type:text   comment:text --force && rails db:migrate:redo


class AirTableRecord < ApplicationRecord
end
