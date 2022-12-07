require 'rake'
class MigrationTaskLaunchJob < ActiveJob::Base
  queue_as :default

  def perform(task_name, arguments)
    Rake::Task[task_name].invoke(*arguments)
  end
end