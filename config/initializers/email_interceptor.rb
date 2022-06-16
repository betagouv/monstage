Rails.application.configure do
  if Rails.env.review? || Rails.env.staging? || Rails.env.development?
    config.action_mailer.interceptors = %w[Interceptors::RerouteEmailInterceptor]
  end
end