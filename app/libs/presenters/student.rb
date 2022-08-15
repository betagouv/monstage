module Presenters
  class Student < User

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

    def birth_date
      return anonymized_message if student.anonymized?

      student.birth_date.strftime('%d/%m/%Y')
    end

    def student
      user
    end

    private

    def anonymized_message
      "Non communiqué (Donnée anonymisée)"
    end
  end
end
