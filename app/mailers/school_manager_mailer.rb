class SchoolManagerMailer < ApplicationMailer
  def new_member(school_manager:, member:)
    @member_presenter = ::Presenters::User.new(person: member)
    @school_manager_presenter = ::Presenters::User.new(person: school_manager)

    mail(subject: "Nouveau #{@member_presenter.role_name}: #{@member_presenter.full_name}",
         to: school_manager.email)
  end
end
