# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Proc.new {  ApplicationMailer.formatted_email }
  layout 'mailer'

  def self.from
    host_or_default = ENV.fetch('HOST') { 'https://test.example.com' }
    domain_without_www = URI(host_or_default).host.gsub('www.', '')
    "ne-pas-repondre@#{domain_without_www}"
  end

  def self.formatted_email
    address = Mail::Address.new(self.from)
    address.display_name = "Mon Stage de 3e"
    address.format.inspect
  end
end
