class AddUuidToInternshipApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_applications, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :internship_applications, :uuid, unique: true
  end
end
