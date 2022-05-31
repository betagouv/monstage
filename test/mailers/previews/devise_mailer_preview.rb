class DeviseMailerPreview < ActionMailer::Preview
  %w[Employer
     Operator
     Statistician
     MinistryStatistician
     Student].map do |user|
    define_method(:"confirmation_instructions_#{user.downcase}") do
      CustomDeviseMailer.confirmation_instructions(
        Users.const_get(user).first,
        'token',
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
        'token',
        {}
      )
    end
  end

  def update_email_instructions
    user = Users::Student.first
    user.unconfirmed_email = 'new@email.fr'
    CustomDeviseMailer.update_email_instructions(user, 'token', {})
  end

  def add_email_instructions
    user = Users::Student.first
    user.unconfirmed_email = 'new@email.fr'
    CustomDeviseMailer.add_email_instructions(user)
  end

  def password_change
    CustomDeviseMailer.password_change(Users::Student.first, {})
  end

  def reset_password_instructions
    CustomDeviseMailer.reset_password_instructions(Users::Student.first, 'token')
  end
end
