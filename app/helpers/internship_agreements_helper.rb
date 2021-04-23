module InternshipAgreementsHelper
  def current_user_agreement_terms(user)
    return :school_manager_accept_terms if user.school_manager?
    return :main_teacher_accept_terms if user.main_teacher?
    return :employer_accept_terms if user.employer?
    return :tutor_accept_terms if user.tutor?

    raise  ArgumentError, "#{user.type} does not support accept terms yet "
  end
end
