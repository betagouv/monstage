class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = [ENV['RECETTE_EMAIL']]
  end
end
