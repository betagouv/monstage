module Presenters
  class School
    def select_text_method
      "#{school.name} - #{school.city} - #{school.zipcode}"
    end

    def agreement_address
      return select_text_method if select_text_method.match(/^\s*Collège.*/)

      "Collège #{select_text_method}"
    end

    private

    attr_accessor :school

    def initialize(school)
      @school = school
    end
  end
end