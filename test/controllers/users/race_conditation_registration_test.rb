require 'test_helper'

class RaceCondidationRegistrationTest < ActionDispatch::IntegrationTest
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

  test 'sentry#1245741475s' do
    email = 'william78320@hotmail.com'
    existing = create(:student, email: email, confirmed_at: nil)
    school = create(:school)
    class_room = create(:class_room, school: school)
    birth_date = 14.years.ago

    post user_registration_path(
      params: {
        user: {
          accept_terms: 1,
          birth_date: birth_date,
          class_room_id: class_room.id,
          email: email,
          first_name: 'william',
          gender: 'm',
          handicap: nil,
          handicap_present: 0,
          last_name: 'pineau',
          password: 'okokok',
          password_confirmation: 'okokok',
          school: {
            city: 'Élancourt'
          },
          school_id: school.id,
          type: 'Users::Student'
        }
      }
    )
    assert_redirected_to users_registrations_standby_path(id: User.last.id)
  end
end
