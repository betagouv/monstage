module Presenters
  module Reporting
    # base class to expose AR collection in CSV/tabular content
    class BaseDimension
      private
      attr_reader :instance
      def initialize(instance)
        @instance = instance
      end
    end
  end
end
