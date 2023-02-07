
module Presenters
  module Dashboard
    class Organisation
      def full_address
        "#{organisation.street}, #{organisation.zipcode} #{organisation.city}"
      end

      attr_reader :organisation

      private

      def initialize(organisation)
        @organisation = organisation
      end
    end
  end
end
