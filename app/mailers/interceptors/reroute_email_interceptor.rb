module Interceptors
  class RerouteEmailInterceptor
    def self.delivering_email(mail)
      original_to = mail.header[:to].to_s
      original_subject = mail.header[:subject].to_s
      mail.to = rerouted_email_address
      mail.subject = "#{original_subject} [initialement adressé à : #{original_to}]"
      if mail.cc.present?
        original_cc_emails = mail.cc.dup.join(", ")
        mail.cc = []
        mail.subject = "#{mail.subject} | Les personnes destinataires étaient initialement [cc: #{original_cc_emails}, to: #{original_to}] "
      end
      Rails.logger.info "================================================================="
      Rails.logger.info "Mail rerouté vers '#{original_to}' to '#{rerouted_email_address}'."
      Rails.logger.info "================================================================="
    end

    def self.rerouted_email_address
      destination = 'recette' if Rails.env.staging?
      destination = 'review'  if Rails.env.review?
      destination ||= nil

      "#{destination}@monstagedetroisieme.fr"
    end
  end
end
