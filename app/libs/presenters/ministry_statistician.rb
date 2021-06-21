module Presenters
  class MinistryStatistician
    def profile_filters
      {
        dashboard: {
          by_school_year: true,
          by_academy: false,
          by_department: true,
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

    def offer_export_mail_subject(department: nil)
      "Export des offres de l'administration : #{ministry_filename}"
    end

    def ministry_filename
      I18n.transliterate(
        ministry_statistician.ministry.name
      )
    end


    private
    attr_reader :ministry_statistician

    def initialize(ministry_statistician)
      @ministry_statistician = ministry_statistician
    end
  end
end
