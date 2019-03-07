class ApplicationController < ActionController::Base
  delegate :current_user, to: :session_manager
  helper_method :current_user

  rescue_from(CanCan::AccessDenied) do |error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  private
  def session_manager
    @session_manager ||= SessionManager.new(request: request,
                                            session: session)
  end
end
