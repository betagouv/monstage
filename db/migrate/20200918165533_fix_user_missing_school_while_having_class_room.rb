class FixUserMissingSchoolWhileHavingClassRoom < ActiveRecord::Migration[6.0]
  def up
    schools_not_found = 0
    roles             = %w[other main_teacher teacher]
    users             = []

    roles.each do |role|
      users += User.where(role: role).where(school_id: nil).where.not(class_room_id: nil)
    end

    users.each do |user|
      class_room = ClassRoom.find_by(id: user.class_room_id)
      school_id = class_room.try(:school_id)
      school_id.nil? ? schools_not_found += 1 : user.update(school_id: school_id)
    end
    message = "schools_not_found : #{schools_not_found}"
    message = 'Everything should be ok' if schools_not_found.zero?
    puts message
  end

  def down
  end
end
