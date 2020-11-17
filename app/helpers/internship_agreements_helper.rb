module InternshipAgreementsHelper
  def current_user_agreement_terms(user)
    return nil unless user
    return :school_manager_accept_terms if user.is_a?(Users::SchoolManagement)
    return :employer_accept_terms if user.is_a?(Users::Employer)
    raise  ArgumentError, "#{user.type} does not support accept terms yet "
  end
end
