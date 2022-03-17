module Phonable
  def by_phone?
    [params[:user]&.[](:channel),
     params[:channel]].compact.first == 'phone'
  end

  def safe_phone_param
    [params[:user]&.[](:phone), params[:phone]].compact
                                               .first
                                               .try(:delete, ' ')
  end

  def clean_phone_param
    params[:user][:phone] = by_phone? ? safe_phone_param : nil
  end

  def fetch_user_by_phone
    return nil if safe_phone_param.blank?

    @user ||= User.where(phone: safe_phone_param).first
  end
end
