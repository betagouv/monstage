if Rails.env.staging? || Rails.env.review?
  ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
end
