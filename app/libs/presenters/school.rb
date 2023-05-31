module Presenters
  class School
    def select_text_method
      "#{school_name} - #{school.city} - #{school.zipcode}"
    end
    alias_method :agreement_address, :select_text_method

    def school_name
      return school.name if school.name.match(/^\s*Collège.*/)

      "Collège #{school.name}"
    end

    def school_name_in_sentence
      return school.name if school.name.match(/^\s*Collège.*/)

      "collège #{school.name}"
    end

    def address
      if school.street.nil?
        "#{'.' * 75}, #{school.zipcode} #{school.city}"
      else
        "#{school.street}, #{school.zipcode} #{school.city}"
      end
    end

    def fetched_phone
      fetch_details if fetched_school_phone.nil?
      fetched_school_phone
    end

    def fetched_address
      fetch_details if fetched_school_address.nil?
      fetched_school_address
    end

    def fetched_email
      fetch_details if fetched_school_email.nil?
      fetched_school_email
    end

    def staff
      %i(main_teachers teachers others).map do |role|
        school.send(role).kept.includes(:school)
      end.flatten
    end

    private

    def fetch_details
      Services::SchoolDirectory.new(school: school).school_data_search
      school.reload
    end

    attr_accessor :school

    def initialize(school)
      @school = school
    end
  end
end