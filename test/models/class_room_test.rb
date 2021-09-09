# frozen_string_literal: true

require 'test_helper'

class ClassRoomTest < ActiveSupport::TestCase
  test '#anonymize' do
    travel_to(DateTime.new(2019, 3, 1, 0, 0, 0)) do
      class_room = create(:class_room)
      class_room.anonymize
      archived_class_room = ClassRoom.find_by(anonymized: true)

      assert_equal class_room.id, archived_class_room.id
      assert_equal 'classe archivée', archived_class_room.name
      assert class_room.anonymized
    end
  end
end
