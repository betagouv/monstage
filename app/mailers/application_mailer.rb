# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "ne-pas-repondre@#{URI(ENV.fetch('HOST')).host.gsub('www.', '')}"
  layout 'mailer'
end
