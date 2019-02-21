module SessionManagerTestHelper
  def sign_in(as:)
    mock = Minitest::Mock.new()
    mock.expect :change_or_restore_current_user, as
    SessionManager.stub :new, mock do
      yield
    end
  end
end
