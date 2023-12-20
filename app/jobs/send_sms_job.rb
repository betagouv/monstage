# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(user: , message: , phone_number: nil)
    return if phone_number.nil? && user.phone.blank?
    return if message.blank? || message.length > 318

    phone = phone_number || User.sanitize_mobile_phone_number(user.phone, '33')

    Services::SmsSender.new(phone_number: phone, content: message)
                       .perform
  end
end

