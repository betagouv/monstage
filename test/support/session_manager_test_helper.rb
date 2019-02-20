module SessionManagerTestHelper
  def sign_in(as:)
    mock = Minitest::Mock.new()
    mock.expect :current_user, as
    SessionManager.stub :new, mock do
      session_manager = SessionManager.new
      session_manager.current_user
    end
  end
end
