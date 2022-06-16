module Presenters
  class God < User

    def profile_filters
      {
        dashboard: {
          by_school_year: true,
          by_academy: false,
          by_department: true,
          by_typology: false,
          by_detailed_typology: false,
          by_subscribed_school: false
        },
        internship_offers: {
          by_school_year: true,
          by_academy: true,
          by_department: true,
          by_typology: true,
          by_detailed_typology: false,
          by_subscribed_school: false
        },
        schools: {
          by_school_name: true,
          by_school_year: false,
          by_academy: false,
          by_department: true,
          by_typology: false,
          by_detailed_typology: false,
          by_subscribed_school: true
        },
        associations: {},
        employers_internship_offers: {
          by_school_year: true,
          by_academy: false,
          by_department: true,
          by_typology: false,
          by_detailed_typology: true,
          by_subscribed_school: false
        }
      }
    end
  end
end
