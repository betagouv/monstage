class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.subject = "[Adresssé initialement à #{message.to}] | #{message.subject}"
    message.to = [ENV['RECETTE_EMAIL']] if Rails.env.staging?
    message.to = [ENV['REVIEW_EMAIL']] if Rails.env.review?
  end
end
