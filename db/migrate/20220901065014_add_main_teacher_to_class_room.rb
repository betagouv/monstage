class AddMainTeacherToClassRoom < ActiveRecord::Migration[7.0]
  def change
    add_column :class_rooms, :main_teacher_id, :integer
  end
end
