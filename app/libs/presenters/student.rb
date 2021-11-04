module Presenters
  class Student
    def name
      return anonymized_message if student.anonymized?
      student.name
    end

    def school_name
      return anonymized_message if student.anonymized?
      student.school.name
    end

    def school_city
      return anonymized_message if student.anonymized?
      student.school.city
    end

    def age
      return anonymized_message if student.anonymized?
      "#{student.age} ans"
    end

    def email
      return student.email_domain_name if student.anonymized?
      student.email
    end

    def phone
      return anonymized_message if student.anonymized?
      student.phone
    end

    private
    attr_reader :student

    def anonymized_message
      "Non communiqué (Donnée anonymisée)"
    end

    def initialize(student)
      @student = student
    end
  end
end
