class SessionManager
  def current_user
    change_user if change_user?
    return user_in_session if user_in_session?
    return MockUser::Visitor
  end

  private
  attr_reader :request, :session
  def initialize(request:, session:)
    @request = request
    @session = session
  end


  def user_in_session
    "MockUser::#{request.params.fetch(:as)}".constantize
  end

  def user_in_session?
    session[:user].present?
  end

  def change_user?
    request.params.key?(:as) && MockUser::const_get(session[:user])
  rescue NameError => e
    false
  end

  def change_user
    session[:user] = request.params.fetch(:as)
  end
end
