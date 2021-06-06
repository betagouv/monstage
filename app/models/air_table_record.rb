# generated with: rails g model AirTableRecord school_name:text organisation_name:text department_name:text sector_name:text is_public:boolean nb_spot_available:integer nb_spot_used:integer nb_spot_male:integer nb_spot_female:integer school_track:text internship_offer_type:text   comment:text --force && rails db:migrate:redo

class AirTableRecord < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :school, optional: true
  belongs_to :sector, optional: true
  belongs_to :week, optional: true

  # AIRtable relationship
  INTERNSHIP_OFFER_TYPE = {
    onsite_internship_offer: "Stage",
    remote_internship_offer: "Stage à distance",
    hybrid_internship_offer: "Stage hybride",
    conference: "Conférence métier",
    workshow: "Atelier"
  }.freeze

  scope :last_modified_at, lambda {
    maximum(:updated_at)
  }

  # where clauses
  scope :during_year, lambda { |school_year:|
    where(week_id: Week.selectable_for_school_year(school_year: school_year.next_year))
  }

  scope :by_department, lambda { |department:|
    where(department_name: department)
  }

  scope :countable_in_grand_total, lambda {
    where(internship_offer_type: [
      INTERNSHIP_OFFER_TYPE[:onsite_internship_offer],
      INTERNSHIP_OFFER_TYPE[:remote_internship_offer],
      INTERNSHIP_OFFER_TYPE[:hybrid_internship_offer]
    ])
  }


  # aggregates
  scope :by_type, -> {
    select("sum(nb_spot_used) as total_count, internship_offer_type")
      .group(:internship_offer_type)
  }

  scope :by_publicy, ->{
    select("sum(nb_spot_used) as total_count, is_public")
      .group(:is_public)
  }

  scope :by_pacte, lambda {
    select("sum(nb_spot_used) as total_count")
      .where(group_id: Group.is_pacte)
  }

end
