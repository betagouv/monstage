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

    def gender_text
      return '' if student.gender.blank? || student.gender.eql?('np')
      return 'Madame' if student.gender.eql?('f')
      return 'Monsieur' if student.gender.eql?('m')

      ''
    end

    def formal_name
      "#{gender_text} #{first_name.try(:capitalize)} #{last_name.try(:capitalize)}"
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
