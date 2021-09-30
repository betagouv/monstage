class UpdateInternshipsTablesMaxStudentGroupSizeField < ActiveRecord::Migration[6.1]
  def up
    change_table :internship_offer_infos do |t|
      t.rename :max_student_group_size, :max_students_per_group
    end
    change_table :internship_offers do |t|
      t.rename :max_student_group_size, :max_students_per_group
    end
  end

  def down
    change_table :internship_offer_infos do |t|
      t.rename :max_students_per_group, :max_student_group_size
    end
    change_table :internship_offers do |t|
      t.rename :max_students_per_group, :max_student_group_size
    end
  end
end
