class SessionManager
  def current_user
    change_user if change_user?
    return user_in_session if user_in_session?
    return User::Visitor
  end

  private
  attr_reader :request, :session
  def initialize(request:, session:)
    @request = request
    @session = session
  end

  def user_in_session
    session[:user]
  end

  def user_in_session?
    session[:user].present?
  end

  def change_user?
    request.params.key?(:as) && User.const_get(request.params.fetch(:as))
  rescue NameError => e
    false
  end

  def change_user
    session[:user] = User.const_get(request.params.fetch(:as))
  end


end
