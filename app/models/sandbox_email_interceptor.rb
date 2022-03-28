class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = [ENV['RECETTE_EMAIL']] if Rails.env.staging?

    original_to = message.to
    message.subject = "[Adresssé initialement à #{original_to}] | #{message.subject}"
    message.to = [ENV['REVIEW_EMAIL']] if Rails.env.review?
  end
end
