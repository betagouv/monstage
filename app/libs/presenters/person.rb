module Presenters
  class Person
    def full_name
      "#{person.first_name} #{person.last_name}"
    end

    private
    attr_reader :person
    def initialize(person:)
      @person = person
    end
  end
end
