module Presenters
  class User
    def full_name
      "#{person.first_name} #{person.last_name}"
    end

    def role_name
      person.model_name.human
    end

    private
    attr_reader :person
    def initialize(person:)
      @person = person
    end
  end
end
