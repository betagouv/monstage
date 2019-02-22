module SessionManagerTestHelper
  def sign_in(as:)
    mock = Minitest::Mock.new()
    mock.expect :current_user, as
    mock.expect :current_user, as
    mock.expect :current_user, as
    mock.expect :current_user, as
    SessionManager.stub :new, mock do
      yield
    end
  end
end
