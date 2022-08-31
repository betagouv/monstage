# frozen_string_literal: true

require 'test_helper'

class ClassRoomTest < ActiveSupport::TestCase
  test "class room's main teacher is the last one" do
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, school: school)
    main_teacher_1 = create(:main_teacher, school: school, class_room: class_room)

    assert_equal(main_teacher_1, class_room.main_teacher)

    main_teacher_2 = create(:main_teacher, school: school, class_room: class_room)

    assert_equal(main_teacher_2, class_room.main_teacher)

    main_teacher_1.class_room = class_room
    main_teacher_1.save

    assert_equal(main_teacher_1, class_room.main_teacher)
  end
end
