require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "School manager creation" do
    school_manager = Users::SchoolManager.create(email: 'chef@etablissement.com',
                                                 password: 'tototo',
                                                 password_confirmation: 'tototo',
                                                 first_name: 'Chef',
                                                 last_name: 'Etablissement',
                                                 school: build(:school))

    assert school_manager.invalid?
    assert_not_empty school_manager.errors[:email]

    school_manager = Users::SchoolManager.create(email: 'chef@ac-etablissement.com',
                                                 password: 'tototo',
                                                 password_confirmation: 'tototo',
                                                 first_name: 'Chef',
                                                 last_name: 'Etablissement',
                                                 school: build(:school))
    assert school_manager.valid?
  end
end
