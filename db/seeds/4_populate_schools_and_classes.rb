def populate_schools
  school_file_name = Rails.env == 'review' ? 'seed-schools-light.csv' : 'seed-schools.csv'
  CSV.foreach(Rails.root.join("db/data_imports/#{school_file_name}"),
              headers: { col_sep: ',' }).each.with_index do |row, i|
    next if i.zero?

    next if School.find_by(code_uai: row['Code UAI'])

    school = School.find_or_create_by!(
      code_uai: row['Code UAI'],
      name: row['ETABLISSEMENT'],
      city: row['Commune'],
      department: row['Département'],
      zipcode: row['zipcode'],
      coordinates: geo_point_factory_array(JSON.parse(row['coordinates'])['coordinates'])
    )
  end
end

def populate_class_rooms
  school = find_default_school_during_test

  ClassRoom.create(name: '3e A', school:)
  ClassRoom.create(name: '3e B', school:)
  ClassRoom.create(name: '3e C', school:)
end

def find_default_school_during_test
  # School.find_by_code_uai("0781896M") # school at mantes lajolie, school name : Pasteur.
  School.find_by_code_uai('0752694W') # school at Paris, school name : Camille Claudel.
end

def missing_school_manager_school
  School.find_by_code_uai('0755030K') # school at Pairis (Ardennes), school name : Daniel Mayer.
end

# used for application
def populate_school_weeks
  school = find_default_school_during_test
  # used for application
  school.weeks = Week.selectable_on_school_year.limit(5) + Week.from_date_for_current_year(from: Date.today).limit(1)
  school.save!

  # used to test matching between internship_offers.weeks and existing school_weeks
  other_schools = School.nearby(latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude],
                                radius: 60_000).limit(4)
                        .where.not(id: school.id)
  other_schools.each.with_index do |another_school, i|
    another_school.update!(weeks: Week.selectable_on_school_year.limit(i + 1))
  end
  missing_school_manager_school.update!(weeks: Week.selectable_on_school_year.limit(3))
end

call_method_with_metrics_tracking(%i[
                                    populate_schools
                                    populate_class_rooms
                                    populate_school_weeks
                                  ])
