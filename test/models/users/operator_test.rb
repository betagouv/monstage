require 'test_helper'
module Users
  class OperatorTest < ActiveSupport::TestCase
    test "creation fails" do
      operator = create(:operator)
      user_operator = Users::Operator.create(first_name: 'Martin',
                                             last_name: 'Fourcade',
                                             email: 'hello@ho.bye',
                                             password: 'okokok',
                                             operator_id: operator.id)
      assert_equal operator, user_operator.operator
    end
  end
end
