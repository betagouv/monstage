require 'test_helper'
module Users
  class SutdentTest < ActiveSupport::TestCase

    test 'Student should not be able to authenticate if parental consent was not received by teacher' do
      student = create(:student, has_parental_consent: false)

      refute student.active_for_authentication?

      student.update(has_parental_consent: true)
      assert student.active_for_authentication?
    end
  end
end
