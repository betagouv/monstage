class UpdatePacteColumnInGroupTable < ActiveRecord::Migration[6.1]
  def up
    change_table :groups do |t|
      t.rename :is_pacte, :is_paqte
    end
  end
  def down
    change_table :groups do |t|
      t.rename :is_paqte, :is_pacte
    end
  end
end
