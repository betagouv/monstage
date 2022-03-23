class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = [ENV['RECETTE_EMAIL']] if Rails.env.staging?
    message.to = [ENV['REVIEW_EMAIL']] if Rails.env.review?
  end
end
