# frozen_string_literal: true

class UserManager
  # Avoid user Users.const_get,
  # otherwise expose RCE: params[:as]=Kernel.eval("do some magick")
  ROLES_BY_PARAMS = {
    'Employer' => Users::Employer,
    'MainTeacher' => Users::MainTeacher,
    'Other' => Users::Other,
    'SchoolManager' => Users::SchoolManager,
    'Student' => Users::Student,
    'Teacher' => Users::Teacher,
    'Operator' => Users::Operator
  }.freeze

  # raises KeyError whe can't find expected role
  def by_params(params:)
    key = params[:as]
    key ||= String(params.dig(:user, :type)).demodulize

    ROLES_BY_PARAMS.fetch(key)
  end

  def valid?(params:)
    true if by_params(params: params)
  rescue KeyError => e
    false
  end
end
