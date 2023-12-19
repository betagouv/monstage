# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(user: , content: , phone_number: nil)
    return if phone_number.nil? && user.phone.blank?
    return if content.blank? || content.length > 318

    phone = phone_number || User.sanitize_mobile_phone_number(user.phone, '33')

    Services::SmsSender.new(phone_number: phone, content: content)
                       .perform
  end
end

