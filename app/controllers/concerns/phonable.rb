module Phonable
  def by_phone?
    # this is specific to students
    [params[:user]&.[](:channel),
     params[:channel]].compact.first == 'phone'
  end

  def safe_phone_param
    [params[:user]&.[](:phone), params[:phone]].compact
                                               .first
                                               .try(:delete, ' ')
  end

  def clean_phone_param
    params[:user][:phone] = (by_phone? && params[:as] == 'Student') ? safe_phone_param : nil
  end

  def fetch_user_by_phone
    return nil if safe_phone_param.blank?

    @user ||= User.where(phone: safe_phone_param).first
  end

  def split_phone_parts(user)
    return [nil, nil] if user.phone.blank?

    sep = 2 if user.phone.size == 13 # France métropolitaine case (+33 case)
    sep = 3 if user.phone.size == 14
    user.phone_prefix, user.phone_suffix = user.phone[0..sep], user.phone[(sep+1)..-1]
  end
end
