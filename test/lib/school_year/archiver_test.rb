# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class ArchiverTest < ActiveSupport::TestCase
    test '.archive_class_rooms ' do
      class_room_name_recreated = 'renew'
      school = create(:school)
      class_room = create(:class_room, name: class_room_name_recreated,
                                       school_id: school.id)
      archiver = SchoolYear::Archiver.new

      assert_changes -> { class_room.reload.anonymized? },
                     from: false,
                     to: true do
        archiver.archive_class_rooms
      end
      assert 1, ClassRoom.current
                         .where(name: class_room_name_recreated,
                                school_id: school.id)
                         .count
    end
  end
end
