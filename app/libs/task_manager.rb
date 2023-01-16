require 'pretty_console'
# Use Sample : 
# tm = TaskManager.new(
#   allowed_environments: %w[development test],
#   task_name: 'say_something',
#   arguments: ['once_str, only_str']
# ).play_task_once(run_with_a_job: false)

# Use Sample (will be played as a job)
# TaskManager.new(
#   allowed_environments: %w[all],
#   task_name: 'migration:do_something',
# ).play_task_once 
class TaskManager
  def play_task_once(run_with_a_job: true)
    if messages_checking_tasks_ok.present?
      PrettyConsole.puts_in_red(messages_checking_tasks_ok.join("\n"))
    elsif last_played.present?
      message = "Task #{task_name} has been played once already at : " \
                "#{last_played.played_at.strftime('%d %B %Y')}"
      PrettyConsole.puts_in_blue(message)
    else
      process_task(run_with_a_job: run_with_a_job)
    end
  end

  #=============================================================================
  # tasks are played only in the allowed environments each time, EVEN when rolling back !
  # this can be worked around by using up and down methods in the migration
  #=============================================================================
  def play_task_each_time(run_with_a_job: true)
    if messages_checking_tasks_ok.present?
      PrettyConsole.puts_in_red(messages_checking_tasks_ok.join("\n"))
    else
      process_task(run_with_a_job: run_with_a_job)
    end
  end

  attr_accessor :allowed_environments, :played_at, :task_name, :arguments, :actual_environment

  private

  def initialize(allowed_environments:, task_name:, arguments: [])
    @allowed_environments = (allowed_environments == %w[all]) ? %w[development test review staging production] : allowed_environments
    @actual_environment = Rails.env
    @task_name = task_name
    @arguments = arguments
  end

  def process_task(run_with_a_job:)
    task_to_register = TaskRegister.new(
      task_name: task_name,
      used_environment: actual_environment,
      played_at: Time.zone.now
    )
    if task_to_register.valid? && check_environment_context?
      task_to_register.save
      PrettyConsole.say_in_green("Task #{task_name}#{arguments} will be played as a #{run_with_a_job ? 'job' : 'task'}")
      if run_with_a_job
        MigrationTaskLaunchJob.perform_now(task_name, arguments)
      else
        Rake.application[task_name].invoke(*arguments)
      end
      PrettyConsole.say_in_green("Task #{task_name}#{arguments} has been played as a task") unless run_with_a_job
    else
      PrettyConsole.puts_in_red(task_to_register.errors.full_messages.join("\n"))
    end
  end

  def messages_checking_tasks_ok
    messages = []
    messages << "Task has no name ..." if task_name.blank?
    messages << "Task #{task_name} does not exist " \
                "please check the spelling" unless task_defined?
    return messages unless task_defined?

    messages <<  "A declared environment for #{task_name}#{arguments} " \
                 "does not exist, it has to be chosen from " \
                 "#{TaskRegister::ALLOWED_ENVIRONMENTS.join(', ')}" unless check_inclusion_in_list?
    unless check_environment_context?
      PrettyConsole.puts_in_yellow(
        "#{task_name} is not executed in this environment")
    end
    messages
  end

  def last_played
    former_registration = TaskRegister.find(task_name: task_name,
                                            used_environment: actual_environment)
  end


  def task_defined?
    Rake::Task.task_defined?(task_name)
  end

  def check_inclusion_in_list?
    allowed_environments.all? { |env| TaskRegister::ALLOWED_ENVIRONMENTS.include?(env) }
  end

  def check_environment_context?
    return true if allowed_environments == %w[all]

    actual_environment.in?(allowed_environments)
  end
end
