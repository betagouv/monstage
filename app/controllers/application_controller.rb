class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= session_manager.change_or_restore_current_user
  end

  private
  def session_manager
    @session_manager ||= SessionManager.new(request: request,
                                            session: session)
  end
end
