require "test_helper"

class TaskRegisterTest < ActiveSupport::TestCase
 test 'factory' do
    assert build(:development_task_register).valid?
    assert build(:review_task_register).valid?
    assert build(:staging_task_register).valid?
    assert build(:production_task_register).valid?
  end
end
