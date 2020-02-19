# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, _opts = {})
    if record.is_a?(Users::MainTeacher) || record.is_a?(Users::Student)
      file_path = Rails.root.join('public', 'autorisation_parentale.pdf')
      attachments['autorisation-parentale.pdf'] = File.read(file_path)
    end
    super(record, token, opts = {})
  end
end
