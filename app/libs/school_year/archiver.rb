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
      ClassRoom.current
               .find_each do |class_room|
        class_room.archive
      end
      true
    end

    def say_in_green(str)
      puts "\e[32m=====> #{str} <=====\e[0m"
    end
  end
end
