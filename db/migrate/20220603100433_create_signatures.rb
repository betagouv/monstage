class CreateSignatures < ActiveRecord::Migration[7.0]
  def up
    create_table :signatures do |t|
      t.string :signatory_ip, limit: 40, null: false
      t.datetime :signature_date, null: false
      t.references :internship_agreement, foreign_key: true

      t.timestamps
    end
    execute <<-SQL
      CREATE TYPE agreement_signatory_role AS ENUM ('employer', 'school_manager');
    SQL
    add_column :signatures, :signatory_role, :agreement_signatory_role
  end

  def down
    remove_column :signatures, :signatory_role
    execute <<-SQL
      DROP TYPE agreement_signatory_role;
    SQL
    drop_table :signatures
  end
end
