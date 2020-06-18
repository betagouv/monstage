class UpdateCancelMessageInInternShipApplication < ActiveRecord::Migration[6.0]
  def up
    # rename_column :internship_applications, :cancel_message, :cancel_message_by_employer
    execute <<-SQL
      UPDATE action_text_rich_texts set name='canceled_by_employer_message' where(name like 'canceled_message') ;
    SQL
  end
  def down
    execute <<-SQL
      UPDATE action_text_rich_texts set name='canceled_message' where(name like 'canceled_by_employer_message') ;
    SQL
  end
end
