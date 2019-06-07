# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Proc.new { ApplicationMailer.from }
  layout 'mailer'

  def self.from
    host_or_default = ENV.fetch('HOST') { 'https://test.example.com' }
    domain_without_www = URI(host_or_default).host.gsub('www.', '')
    "ne-pas-repondre@#{domain_without_www}"
  end
end
