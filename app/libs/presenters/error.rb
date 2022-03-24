module Presenters
  class Error
    # When error message is 'none', error is not displayed nor counted
    attr_reader :error, :displayed_messages, :count

    private

    def initialize(errors:)
      @errors = errors
      @messages = errors.messages
      @displayed_messages = selected_messages(messages: @messages)
      @count = @displayed_messages.count
    end

    def selected_messages(messages:)
      res = {}
      @messages.each do |key, errors_message|
        res[key] = errors_message.reject{ |message| message == 'none' }
      end
      res.reject{ |key, error_texts| error_texts.join(', ').blank? }
    end
  end
end
