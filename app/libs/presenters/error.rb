module Presenters
  class Error
    include ActionView::Helpers::TagHelper
    # When error message is 'none', error is not displayed nor counted
    def error_messages(resource_name: , resource: , separator:)
      sanitize_and_translate(
        resource_name: resource_name ,
        resource:resource,
        given_messages: reject_notice_messages(messages: messages)
      ).flatten.join(separator).html_safe
    end

    def notice_messages(resource_name: , resource:)
      sanitize_and_translate(
        resource_name: resource_name ,
        resource:resource,
        given_messages: keep_notice_messages(messages: messages)
      ).flatten
    end

    def field_error_tag(resource_name: , resource:, field: )
      error_message = field_errors(
        resource_name: resource_name,
        resource: resource,
        field: field
      )
      unless error_message.blank?
        content_tag(
          :p,
          error_message,
          id: "p#text-#{field}-input-error-desc-error",
          class: 'fr-error-text fr-mb-3w'
        )
      end
    end

    attr_reader :errors, :displayed_messages, :count, :messages

    private

    def initialize(errors:)
      @errors             = errors
      @messages           = errors.messages
      @displayed_messages = selected_messages(messages: @messages)
      @count              = @displayed_messages.count
    end

    def field_errors(resource_name: , resource:, field: )
      filtered_messages = reject_none_messages(messages: reject_notice_messages(messages: messages))
      filtered_messages = reject_empty_messages(messages: filtered_messages)
      return "" if filtered_messages.blank?

      filtered_messages.select do |key, notice_messages|
        key.to_s == field.to_s
      end.map do |key, notice_messages|
        notice_messages
      end.flatten.join(', ')
    end

    def sanitize_and_translate(resource_name: , resource:, given_messages:)
      filtered_messages = reject_none_messages(messages: given_messages)
      filtered_messages = reject_empty_messages(messages: filtered_messages)
      filtered_messages = reject_only_true_messages(messages: filtered_messages)
      filtered_messages.map do |key, notice_messages|
        translate_path = "activerecord.attributes.#{defined?(resource_name) ? resource_name : resource.class.name.downcase }.#{key}"
        notice_messages.map do |notice_message|
          "<strong>#{I18n.t(translate_path)}</strong> : #{notice_message}"
        end
      end
    end

    def selected_messages(messages:)
      res = {}
      messages.each do |key, errors_message|
        res[key] = errors_message.reject{ |message| message == 'none' }
      end
      res.reject{ |key, error_texts| error_texts.join(', ').blank? }
    end

    def reject_none_messages(messages:)
      res = {}
      messages.each do |key, errors_message|
        res[key] = errors_message.reject{ |message| message == 'none' }
      end
    end

    def reject_notice_messages(messages:)
      messages.reject{ |key, error_texts| key =="notice" }
    end

    def keep_notice_messages(messages:)
      messages.select{ |key, error_texts| key =="notice" }
    end

    def reject_empty_messages(messages:)
      messages.reject{ |key, error_texts| error_texts.join(', ').blank? }
    end

    def reject_only_true_messages(messages:)
      messages.reject{ |key, error_texts| error_texts.join(', ') == 'true' }
    end
  end
end
