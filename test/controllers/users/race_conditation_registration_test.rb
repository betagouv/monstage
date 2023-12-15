require 'test_helper'

class RaceCondidationRegistrationTest < ActionDispatch::IntegrationTest
  # TODO remove this test
  setup do
    class ActiveRecord::Validations::UniquenessValidator
      alias saved_validate_each validate_each
      def validate_each(_record, _attribute, _value)
        true
      end
    end
  end
  teardown do
    class ActiveRecord::Validations::UniquenessValidator
      alias validate_each saved_validate_each
    end
  end
end
