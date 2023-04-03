def make_airtable_rec_id
  az = ('a'..'z').to_a + ('A'..'Z').to_a
  digits = (0..9).to_a
  chars = []
  2.times{ |i| chars << digits.shuffle.first }
  12.times{ |i| chars << az.shuffle.first }
  "rec#{chars.shuffle.join('')}"
end

def populate_airtable_records
  (25..50).to_a.shuffle.first.times do |n|
    AirTableRecord.create!(make_airtable_single_record)
  end
end

def make_airtable_single_record
  is_public = [true, false].shuffle.first
  nb_spot_available =  (30..50).to_a.shuffle.first
  nb_spot_used =  nb_spot_available - (0..7).to_a.shuffle.first
  nb_spot_male = (1..nb_spot_used).to_a.shuffle.first
  group_id = Group.where(is_public: is_public).shuffle.first.id
  random_week = nb_spot_available.even? ? Week.of_previous_school_year : Week.selectable_for_school_year(school_year: SchoolYear::Current.new)
  {
    remote_id: make_airtable_rec_id,
    is_public: is_public,
    nb_spot_available: nb_spot_available,
    nb_spot_used: nb_spot_used,
    nb_spot_male: nb_spot_male,
    nb_spot_female: nb_spot_used - nb_spot_male,
    department_name: Department::MAP.values.shuffle.first,
    internship_offer_type: AirTableRecord::INTERNSHIP_OFFER_TYPE.values.shuffle.first,
    comment: nil,
    school_id: School.all.shuffle.first.id,
    group_id: group_id,
    sector_id: Sector.all.shuffle.first.id,
    week_id: random_week.to_a.shuffle.first.id,
    operator_id: Operator.all.to_a.shuffle.first.id,
    created_by: 'tech@monstagedetroisieme.fr'
  }
end

call_method_with_metrics_tracking([:populate_airtable_records])