class SchoolManagerMailerPreview < ActionMailer::Preview
  def missing_school_weeks
    SchoolManagerMailer.missing_school_weeks(
      school_manager: school_manager
    )
  end

  def new_member
    SchoolManagerMailer.new_member(school_manager: school_manager,
                                   member: create_or_fetch_teacher)
  end

  private

  def school_manager
    school_managers = Users::SchoolManagement.where(role: 'school_manager')
    return school_managers.first if school_managers.present?

    FactoryBot.create(
      :school_manager,
      school: School.first,
      email: "perfect-school-manager-#{rand(1..1_000)}@ac-paris.fr"
    )
  end

  def create_or_fetch_teacher
    teachers = Users::SchoolManagement.where(role: 'teacher')
    return teachers.first if teachers.present?

    FactoryBot.create(
      :school_manager,
      school: School.first,
      email: "perfect-school-manager-#{rand(1..1_000)}@ac-paris.fr"
    )
    FactoryBot.create(
      :teacher,
      school: School.first,
      email: "perfect-teacher-#{rand(1..1_000)}@ms3e.fr"
    )
  end

end
