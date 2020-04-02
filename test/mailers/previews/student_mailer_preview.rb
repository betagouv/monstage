
class StudentMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    internship_application = InternshipApplication.approved.first
    message_builder = MessageForAasmState.new(internship_application: internship_application,
                                              aasm_target: :approve!)

    message_builder.assigned_rich_text_attribute
    StudentMailer.internship_application_approved_email(internship_application: internship_application)
  end

  def internship_application_rejected_email
    internship_application = InternshipApplication.rejected.first
    message_builder = MessageForAasmState.new(internship_application: internship_application,
                                              aasm_target: :reject!)

    message_builder.assigned_rich_text_attribute
    StudentMailer.internship_application_rejected_email(internship_application: internship_application)
  end

  def internship_application_canceled_email
    internship_application = InternshipApplication.canceled.first
    message_builder = MessageForAasmState.new(internship_application: internship_application,
                                              aasm_target: :cancel!)

    message_builder.assigned_rich_text_attribute
    StudentMailer.internship_application_canceled_email(internship_application: internship_application)
  end

  def account_activated_by_main_teacher_email
    StudentMailer.account_activated_by_main_teacher_email(user: Users::Student.first)
  end
end
