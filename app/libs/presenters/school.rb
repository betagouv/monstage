module Presenters
  class School
    def select_text_method
      "#{school.name} - #{school.city} - #{school.zipcode}"
    end

    def agreement_address
      "Collège #{school.name} - #{school.city}, #{school.zipcode}"
    end

    private

    attr_accessor :school

    def initialize(school)
      @school = school
    end
  end
end