# frozen_string_literal: true

class SchoolManagerMailer < ApplicationMailer
  def new_member(school_manager:, member:)
    @member_presenter = ::Presenters::User.new(user: member)
    @school_manager_presenter = ::Presenters::User.new(user: school_manager)

    mail(subject: "Nouveau #{@member_presenter.role_name}: #{@member_presenter.full_name}",
         to: school_manager.email)
  end

  def missing_school_weeks(school_manager:)
    @school = school_manager.school
    mail(subject: "Vos élèves souhaiteraient candidater à des offres",
         to: school_manager.email)
  end
end
