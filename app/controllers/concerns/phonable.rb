module Phonable
  def by_phone?
    params[:user][:phone].present? || params[:phone].present?
  end

  def safe_phone_param
    [ params[:user][:phone], params[:phone] ].compact
                                             .first
                                             .delete(' ')
  end

  def fetch_user_by_phone
    @user ||= User.where(phone: safe_phone_param).first
  end
end
