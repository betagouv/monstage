module Presenters
  module Reporting
    class BaseDimension
      # what's the rails way?
      private
      attr_reader :internship_offer
      def initialize(internship_offer)
        @internship_offer = internship_offer
      end
    end
  end
end
