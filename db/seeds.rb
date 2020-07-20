# frozen_string_literal: true

require 'csv'

# school only exists a paris/bdx
class Coordinates
  def self.paris
    { latitude: 48.866667, longitude: 2.333333 }
  end

  def self.bordeaux
    { latitude: 44.837789, longitude: -0.57918 }
  end
end

def populate_week_reference
  first_year = 2019
  last_year = 2050

  first_week = 1
  last_week = 53 # A 53 week exisits! https://fr.wikipedia.org/wiki/Semaine_53

  first_year.upto(last_year) do |year|
    first_week.upto(last_week) do |week| # number of the week
      if week == last_week
        Date.commercial(year, week, 1)
        puts "Special year #{year}, this one have 53 weeks"
      end

      Week.create!(year: year, number: week)
    rescue ArgumentError
      puts "no week #{week} for year #{year}"
    rescue ActiveRecord::RecordNotUnique
      puts "week #{week} - #{year} already exists"
    end
  end
end

def populate_schools
  # ActiveRecord::Base.transaction do
    CSV.foreach(Rails.root.join('db/data_imports/college-rep-plus.csv'), headers: { col_sep: ',' }).each.with_index do |row, i|
      next if i.zero?
      school = School.find_or_create_by!(
        code_uai: row['Code UAI'],
        name: row['ETABLISSEMENT'],
        city: row['Commune'],
        department: row['Département'],
        zipcode: '75015',
        coordinates: geo_point_factory(
            **([1,2].shuffle.first == 1 ?
               Coordinates.paris :
               Coordinates.bordeaux)
        )
      )
    end
  # end
end

def with_class_name_for_defaults(object)
  object.first_name = "user"
  object.last_name = object.class.name
  object.accept_terms = true
  object.confirmed_at = Time.now.utc
  object
end

def populate_operators
  Operator.create!(name: 'MS3E-OPERATOR-1')
  Operator.create!(name: 'MS3E-OPERATOR-2')
end

def populate_sectors
  Sector.create!(name: 'REVIEW-SECTOR-1')
  Sector.create!(name: 'REVIEW-SECTOR-2')
end

def populate_groups
  Group.create!(name: 'PUBLIC GROUP', is_public: true)
  Group.create!(name: 'PRIVATE GROUP', is_public: false)
end

def populate_users
  with_class_name_for_defaults(Users::Employer.new(email: 'employer@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::God.new(email: 'god@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::Operator.new(email: 'operator@ms3e.fr', password: 'review', operator: Operator.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'school_manager', email: 'school_manager@ac-ms3e.fr', password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', email: 'main_teacher@ms3e.fr', password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'other', email: 'other@ms3e.fr', password: 'review', school: School.first)).save!
  email_whitelist = EmailWhitelist.create!(email: 'statistician@ms3e.fr', zipcode: 60)
  with_class_name_for_defaults(Users::Statistician.new(email: 'statistician@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student@ms3e.fr', password: 'review', school: School.first, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'teacher', email: 'teacher@ms3e.fr', password: 'review', school: School.first)).save!
end

def populate_internship_offers
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    weeks: Week.selectable_on_school_year,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Offre 3e/collège',
    description_rich_text: 'une offre au top',
    employer_description_rich_text: 'maraichers',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
  )
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    weeks: Week.selectable_on_school_year,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Offre de partenaire 3e uniquement',
    description_rich_text: 'une offre au top',
    employer_description_rich_text: 'maraichers',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: '1',
    permalink: 'https://www.google.fr',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
  )
  InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Offre lycee',
    description_rich_text: 'une offre au top',
    employer_description_rich_text: 'maraichers',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
  )
end

if Rails.env == 'review'
  populate_week_reference
  populate_schools
  School.update_all(updated_at: Time.now)
  populate_operators
  populate_users
  populate_sectors
  populate_groups
  populate_internship_offers
end
