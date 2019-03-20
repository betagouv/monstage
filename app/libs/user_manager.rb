class UserManager
  # Avoid user Users.const_get,
  # otherwise expose RCE: params[:as]=Kernel.eval("do some magick")
  ROLES_BY_PARAMS = {
    'Cpe' => Users::Cpe,
    'Employer' => Users::Employer,
    'Librarian' => Users::Librarian,
    'MainTeacher' => Users::MainTeacher,
    'Other' => Users::Other,
    'Psychologist' => Users::Psychologist,
    'SchoolManager' => Users::SchoolManager,
    'Secretary' => Users::Secretary,
    'Student' => Users::Student,
    'Teacher' => Users::Teacher,
  }.freeze

  # raises KeyError whe can't find expected role
  def by_params(params:)
    key = params[:as]
    key ||= params.dig(:user, :type)&.demodulize
    ROLES_BY_PARAMS.fetch(key)
  end
end
