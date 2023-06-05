class AddSchoolPhoneToSchools < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :fetched_school_phone, :string, limit: 20, null: true
    add_column :schools, :fetched_school_address, :string, limit: 300, null: true
    add_column :schools, :fetched_school_email, :string, limit: 100, null: true
  end
end
