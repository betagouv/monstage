require 'task_manager'
class CreateTaskRegisters < ActiveRecord::Migration[7.0]
  def change
    create_table :task_registers do |t|
      t.string :task_name
      t.string :allowed_environment
      t.datetime :played_at
      
      t.timestamps
    end
    TaskManager.new(allowed_environments: 'developement', task_name: 'say_something', arguments: nil)

  end
end
