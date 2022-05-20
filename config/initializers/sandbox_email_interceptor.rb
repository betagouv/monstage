Rails.application.configure do
  if Rails.env.staging? || Rails.env.review?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
