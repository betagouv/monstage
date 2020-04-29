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
  with_class_name_for_defaults(Users::SchoolManager.new(email: 'school_manager@ac-ms3e.fr', password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::MainTeacher.new(email: 'main_teacher@ms3e.fr', password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::Other.new(email: 'other@ms3e.fr', password: 'review', school: School.first)).save!
  email_whitelist = EmailWhitelist.create!(email: 'statistician@ms3e.fr', zipcode: 60)
  with_class_name_for_defaults(Users::Statistician.new(email: 'statistician@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student@ms3e.fr', password: 'review', school: School.first, birth_date: 14.years.ago, gender: 'm', confirmed: 2.days.ago)).save!
  with_class_name_for_defaults(Users::Teacher.new(email: 'teacher@ms3e.fr', password: 'review', school: School.first)).save!
end

if Rails.env == 'review'
  populate_week_reference
  populate_schools
  populate_operators
  populate_users
  populate_sectors
  populate_groups
end
