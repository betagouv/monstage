# custom builder for InternshipOfferBuilder, can have duplicate
module Builders
  class InternshipOfferCallback < Callback
    attr_accessor :on_duplicate
    def duplicate(&block)
      @on_duplicate = block
    end
  end
end
