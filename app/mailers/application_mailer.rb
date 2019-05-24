# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'ne-pas-repondre@monstagede3e.fr'
  layout 'mailer'
end
