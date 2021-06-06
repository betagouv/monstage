# generated with: rails g model AirTableRecord school_name:text organisation_name:text department_name:text sector_name:text is_public:boolean nb_spot_available:integer nb_spot_used:integer nb_spot_male:integer nb_spot_female:integer school_track:text internship_offer_type:text   comment:text --force && rails db:migrate:redo

class AirTableRecord < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :school, optional: true
  belongs_to :sector, optional: true
  belongs_to :week, optional: true

  scope :by_year, lambda { |school_year:|
    where(week_id: Week.selectable_for_school_year(school_year: school_year))
  }

  scope :by_type, -> {
    select("sum(nb_spot_used) as total_count, internship_offer_type")
      .group(:internship_offer_type)
  }

  scope :by_department, lambda { |department:|
    where(department: department)
  }

  scope :by_publicy, ->{
    select("sum(nb_spot_used) as total_count, is_public")
      .group(:is_public)
  }
end
