# frozen_string_literal: true

# custom builder for InternshipOfferBuilder, can have duplicate
module Builders
  class InternshipOfferCallback < Callback
    attr_accessor :on_duplicate, :on_argument_error
    # occurs when remote_id is duplicated
    def duplicate(&block)
      @on_duplicate = block
    end

    # occurs when data is present but invalid
    def argument_error(&block)
      @on_argument_error = block
    end
  end
end
