require 'rake'
class MigrationTaskLaunchJob < ActiveJob::Base
  queue_as :default

  def perform(task_name, arguments)
    Monstage::Application.load_tasks
    Rake::Task[task_name].invoke(*arguments)
  end
end