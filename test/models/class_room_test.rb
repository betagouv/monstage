# frozen_string_literal: true

require 'test_helper'

class ClassRoomTest < ActiveSupport::TestCase
  test '.anonymize' do
    travel_to(DateTime.new(2019, 3, 1, 0, 0, 0)) do
      class_room = create(:class_room)
      ClassRoom.anonymize!
      class_room_discarded = ClassRoom.discarded.first
      assert_equal class_room.id, class_room_discarded.id
      assert_equal 'classe archivée', class_room_discarded.name
      assert_in_delta DateTime.now.utc.to_i,
                      class_room_discarded.discarded_at.to_i,
                      delta=1.hour.to_i
    end
  end
end
