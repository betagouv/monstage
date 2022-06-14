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

    private

    attr_accessor :school

    def initialize(school)
      @school = school
    end
  end
end