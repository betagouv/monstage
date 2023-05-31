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

    def formal_school_name
      school = student.school
      "#{school.name} à #{school.city} (Code U.A.I: #{school.code_uai})"
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

    def sing_feminine(word)
      return "#{word}e" if user.gender == 'f'

      word
    end

    def dashboard_name_link
      url_helpers.dashboard_students_internship_applications_path(student_id: user.id)
    end

    def applicable_weeks(internship_offer)
      if user.school.has_weeks_on_current_year?
        InternshipOfferWeek.applicable(
          user: user,
          internship_offer: internship_offer
        ).map(&:week)
         .uniq
         .sort_by(&:id) & internship_offer.weeks
      else
        internship_offer.weeks.in_the_future
      end
    end

    private

    def anonymized_message
      "Non communiqué (Donnée anonymisée)"
    end
  end
end
