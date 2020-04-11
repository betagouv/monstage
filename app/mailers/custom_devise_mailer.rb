# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, _opts = {})
    super(record, token, opts = {})
  end
end
