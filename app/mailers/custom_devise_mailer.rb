class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts={})
    super(record, token, opts={})
  end
end

