class RenameSchoolPostalCodeToZipCode < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :street, :string
    rename_column :schools, :postal_code, :zipcode
  end
end
