module InternshipAgreementsHelper
  def current_user_agreement_terms(user)
    return :school_manager_accept_terms if user.school_manager?
    return :main_teacher_accept_terms if user.main_teacher?
    return :employer_accept_terms if user.employer_like?
    raise ArgumentError, "#{user.type} does not support accept terms yet "
  end

  def agreement_form?
    return false unless controller.controller_name == 'internship_agreements'
    return false unless ['new', 'edit', 'update'].include?(controller.action_name)
    return true
  end

  def morning_hours_by_quarter
    # 32 => 08:00
    # 33 => 08:15
    # 48 => 12:00
    hours_maker(range: (32..48).to_a)
  end

  def afternoon_hours_by_quarter
    # 72 => 18:00
    hours_maker(range: (52..72).to_a)
  end

  def hours_maker(range: )
    range.map do |i|
      hour = (i.to_f / 4).to_i
      min = 15 * ( i - (hour * 4))
      "#{format('%02d', hour)}:#{format('%02d',min)}"
    end
  end
end
