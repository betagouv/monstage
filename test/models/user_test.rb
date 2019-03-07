require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "School manager creation" do
    school = create(:school)
    school_manager = SchoolManager.create(email: 'chef@etablissement.com', password: 'tototo', password_confirmation: 'tototo', school_id: school.id)

    assert school_manager.invalid?
    assert_not_empty school_manager.errors[:email]

    school_manager = SchoolManager.create(email: 'chef@ac-etablissement.com', password: 'tototo', password_confirmation: 'tototo', school_id: school.id)

    assert school_manager.valid?
  end
end
