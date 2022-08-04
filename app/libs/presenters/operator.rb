module Presenters
  class Operator < User

    def profile_filters
      {
        dashboard: {
          by_school_year: false,
          by_academy: false,
          by_department: false,
          by_typology: false,
          by_detailed_typology: false,
          by_subscribed_school: false,
          by_school_track: false
        },
        internship_offers: {
          by_school_year: true,
          by_academy: false,
          by_department: true,
          by_typology: false,
          by_detailed_typology: false,
          by_subscribed_school: false,
          by_school_track: true
        },
        schools: {
          by_school_name: true,
          by_school_year: false,
          by_academy: false,
          by_department: true,
          by_typology: false,
          by_detailed_typology: false,
          by_subscribed_school: true,
          by_school_track: false
        },
        associations: {},
        employers_internship_offers: {
          by_school_year: true,
          by_academy: false,
          by_department: true,
          by_typology: false,
          by_detailed_typology: false,
          by_subscribed_school: false,
          by_school_track: false
        }
      }
    end
  end
end
