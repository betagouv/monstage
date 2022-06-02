Rails.application.configure do
  if Rails.env.review? || Rails.env.staging?
    config.action_mailer.interceptors = %w[Interceptors::RerouteEmailInterceptor]
  end
end