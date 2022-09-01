# frozen_string_literal: true

desc "Assignation des professeurs principaux à leur classe"
task :20220901_set_class_rooms_main_teachers => :environment do |task|
   ClassRoom.each do |class_room|
      main_teacher = school_managements&.main_teachers&.last

      class_room.upate(main_teacher_id: main_teacher.id) if main_teacher.present?
   end
end
