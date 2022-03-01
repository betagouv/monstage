module InternshipAgreementsHelper
  def current_user_agreement_terms(user)
    return :school_manager_accept_terms if user.school_manager?
    return :main_teacher_accept_terms if user.main_teacher?
    return :employer_accept_terms if user.is_a?(Users::Employer)
    raise ArgumentError, "#{user.type} does not support accept terms yet "
  end

  def agreement_form?
    return false unless controller.controller_name == 'internship_agreements'
    return false unless ['new', 'edit', 'update'].include?(controller.action_name)
    return true
  end
end
