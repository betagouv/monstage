class FixUserMissingSchoolWhileHavingClassRoom < ActiveRecord::Migration[6.0]
  def up
    roles             = %w[other main_teacher teacher]

    roles.each do |role|
      User.where(role: role)
          .where(school_id: nil)
          .where.not(class_room_id: nil)
          .update(class_room_id: nil)
      end
    end

  def down
  end
end
