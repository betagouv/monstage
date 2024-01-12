# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(user: , message: , phone_number: nil, campaign_name: nil)
    return if phone_number.nil? && user.phone.blank?
    return if message.blank? || message.length > 318
    return if campaign_name&.size&.to_i > 59

    phone = phone_number || User.sanitize_mobile_phone_number(user.phone, '33')

    Services::SmsSender.new(phone_number: phone, content: message, campaign_name: campaign_name)
                       .perform
  end
end

