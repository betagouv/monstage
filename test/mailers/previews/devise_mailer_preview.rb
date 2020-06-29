class DeviseMailerPreview < ActionMailer::Preview

  %w[Employer
     Operator
     Statistician
     Student
     ].map do |user|
    define_method(:"confirmation_instructions_#{user.downcase}") do
      CustomDeviseMailer.confirmation_instructions(
        Users.const_get(user).first,
        "token",
        {}
    )
    end
  end

  %w[school_manager
    teacher
    main_teacher
    other].map do |role|
    define_method(:"confirmation_instructions_#{role.downcase}") do
      CustomDeviseMailer.confirmation_instructions(
        Users::SchoolManagement.find_by(role: role),
        "token",
        {}
    )
    end
  end

  def email_change
    user = Users::Student.first
    user.unconfirmed_email = 'new@email.fr'
    CustomDeviseMailer.confirmation_instructions(user, "token", {})
  end

  def password_change
    CustomDeviseMailer.password_change(Users::Student.first, {})
  end

  def reset_password_instructions
    CustomDeviseMailer.reset_password_instructions(Users::Student.first, "token")
  end
end

