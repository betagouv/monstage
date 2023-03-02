# frozen_string_literal: true

class UserManager
  # Avoid user Users.const_get,
  # otherwise expose RCE: params[:as]=Kernel.eval("do some magick")
  ROLES_BY_PARAMS = {
    'Employer' => Users::Employer,
    'SchoolManagement' => Users::SchoolManagement,
    'Student' => Users::Student,
    'Operator' => Users::Operator,
    'Statistician' => Users::PrefectureStatistician,
    'EducationStatistician' => Users::EducationStatistician,
    'MinistryStatistician' => Users::MinistryStatistician
  }.freeze

  PRESENTERS = {
    "Users::Operator" => Presenters::Operator,
    "Users::PrefectureStatistician" => Presenters::PrefectureStatistician,
    "Users::God" => Presenters::God,
    "Users::MinistryStatistician" => Presenters::MinistryStatistician
  }

  # raises KeyError whe can't find expected role
  def by_params(params:)
    key = params[:as]
    key ||= String(params.dig(:user, :type)).demodulize

    ROLES_BY_PARAMS.fetch(key)
  end

  def presenter(user)
    PRESENTERS[user.class.name].new(user)
  rescue KeyError
    Rails.logger.error "this specific user is not implemented yet: #{user.class.name}"
  end

  def valid?(params:)
    true if by_params(params: params)
  rescue KeyError
    false
  end
end
