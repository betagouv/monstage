# frozen_string_literal: true

# see: https://github.com/plataformatec/devise#activejob-integration
module DelayedDeviseEmailSender
  extend ActiveSupport::Concern

  included do
    protected

    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end
  end
end
