class SendSmsJob < ApplicationJob
  queue_as :default

  # TODO add a SMS service class since following is a data clamp

  def perform(user: , message: , phone_number: nil, campaign_name: nil)
    return if phone_number.nil? && user.phone.blank?
    if message.blank? || message.length > 318
      Rails.logger.error("SMS: Message is too long: #{message}") if message&.length&.to_i > 318
      Rails.logger.error("SMS: Message is just blank") if message
      return
    end
    if campaign_name&.size&.to_i > 49
      Rails.logger.error("Campaign name is too long: #{campaign_name}")
      return
    end

    phone = phone_number || User.sanitize_mobile_phone_number(user.phone, '33')

    Services::SmsSender.new(phone_number: phone, content: message, campaign_name: campaign_name)
                       .perform
  end
end