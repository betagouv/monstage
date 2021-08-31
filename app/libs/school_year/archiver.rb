module SchoolYear
  class Archiver
    def perform
      ActiveRecord::Base.transaction do
        archive_students
        say_in_green('So long with the students')
        archive_class_rooms
        say_in_green('So long with the class_rooms')
      end
    end

    def archive_students
      Users::Student.kept
                    .find_each do |student|
        student.archive
      end
      true
    end

    def archive_class_rooms
      class_room_elements = []
      ClassRoom.current
               .find_each do |class_room|
        class_room_elements << ClassRoom.new(class_room.attributes.except!('id', 'created_at', 'updated_at'))
        class_room.archive
      end
      class_room_elements.each do |new_class_room| new_class_room.save! end
      true
    end

    def say_in_green(str)
      puts "\e[32m=====> #{str} <=====\e[0m"
    end
  end
end
