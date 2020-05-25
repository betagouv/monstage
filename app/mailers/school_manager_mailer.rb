# frozen_string_literal: true

class SchoolManagerMailer < ApplicationMailer
  def new_member(school_manager:, member:)
    @member_presenter = ::Presenters::User.new(member)
    @school_manager_presenter = ::Presenters::User.new(school_manager)

    mail(subject: "Nouveau #{@member_presenter.role_name}: #{@member_presenter.full_name}",
         to: school_manager.email)
  end

  def missing_school_weeks(school_manager:)
    @school = school_manager.school
    @school_manager = school_manager
    mail(subject: 'Action requise – Renseignez les semaines de stage de votre établissement',
         to: school_manager.email)
  end
end
