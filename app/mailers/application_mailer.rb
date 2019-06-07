# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Proc.new {  ApplicationMailer.formatted_email("Mon Stage de 3ème") }
  layout 'mailer'

  def self.from
    host_or_default = ENV.fetch('HOST') { 'https://test.example.com' }
    domain_without_www = URI(host_or_default).host.gsub('www.', '')
    "ne-pas-repondre@#{domain_without_www}"
  end

  def self.formatted_email(display_name)
    address = Mail::Address.new(self.from)
    address.display_name = display_name
    address.format
  end
end
