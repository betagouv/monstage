module SchoolYear
  class Archiver
    def perform
      archive_students &&
      archive_class_rooms
    end

    def archive_students
      Users::Student.kept
                    .find_each do |student|
        student.archive
      end
      true
    end

    def archive_class_rooms
      ClassRoom.current
               .find_each do |class_room|
        class_room.archive
      end
      true
    end
  end
end