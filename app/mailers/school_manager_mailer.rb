class SchoolManagerMailer < ApplicationMailer
  def new_main_teacher(school_manager:, main_teacher:)
    @main_teacher_presenter = ::Presenters::Person.new(person: main_teacher)
    @school_manager_presenter = ::Presenters::Person.new(person: school_manager)

    mail(subject: "Nouveau Profésseur Principal Signup: #{@main_teacher_presenter.full_name}",
         to: school_manager.email)
  end
end
