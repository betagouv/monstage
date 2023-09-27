module Api
  # rails 6.1 pluged didyoumean corrections on ParamaterMissing
  # this module prevent DidYouMean to show corrections in API response by swapping its formatter with our own
  module DidYouMeanFormatter
    extend ActiveSupport::Concern

    included do
      # tried with an around_action : but ensure was run before rescued_from
      before_action { DidYouMean.formatter = DidYouMean::ApiNullFormatter.new }
      # after_action { DidYouMean.formatter = DidYouMean::PlainFormatter.new }
    end
  end
end
