require 'pretty_console'
class TaskManager
  def play_task_once
    if messages_checking_tasks_ok.present?
      PrettyConsole.puts_in_red(messages_checking_tasks_ok.join("\n"))
    elsif last_played.present?
      message = "Task #{task_name} has been played once already at : " \
                "#{last_played.played_at.strftime('%d %B %Y')}"
      PrettyConsole.puts_in_blue(message)
    else
      task_to_register = TaskRegister.new(
        task_name: task_name,
        used_environment: actual_environment,
        played_at: Time.zone.now
      )
      if task_to_register.valid? && check_environment_context?
        task_to_register.save
        PrettyConsole.say_in_green("Task #{task_name}#{arguments} will be played once")
        Rake.application[task_name].invoke(*arguments)
        PrettyConsole.say_in_green("Task #{task_name}#{arguments} has been played once")
      else
        PrettyConsole.puts_in_red(task_to_register.errors.full_messages.join("\n"))
      end
    end
  end

  #=============================================================================
  # tasks are played only in the allowed environments each time, EVEN when rolling back !
  # this can be worked around by using up and down methods in the migration
  #=============================================================================
  def play_task_each_time
    if messages_checking_tasks_ok.present?
      PrettyConsole.puts_in_red(messages_checking_tasks_ok.join("\n"))
    else
      task_to_register = TaskRegister.new(
        task_name: task_name,
        used_environment: actual_environment,
        played_at: Time.zone.now
      )
      if task_to_register.valid? && check_environment_context?
        task_to_register.save
        PrettyConsole.say_in_green("Task #{task_name}#{arguments} will be played")
        Rake.application[task_name].invoke(*arguments)
        PrettyConsole.say_in_green("Task #{task_name}#{arguments} has been played")
      else
        PrettyConsole.puts_in_red(task_to_register.errors.full_messages.join("\n"))
      end
    end
  end


  attr_accessor :allowed_environments, :played_at, :task_name, :arguments, :actual_environment

  private

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
        "#{task_name} is never executed in #{actual_environment} environment")
    end
    messages
  end

  def last_played
    former_registration = TaskRegister.find(task_name: task_name,
                                            used_environment: actual_environment)
  end

  def initialize(allowed_environments:, task_name:, arguments: [])
    @allowed_environments = allowed_environments
    @actual_environment = Rails.env
    @task_name = task_name
    @arguments = arguments
  end

  def task_defined?
    Rake::Task.task_defined?(task_name)
  end

  def check_inclusion_in_list?
    allowed_environments.all? { |env| TaskRegister::ALLOWED_ENVIRONMENTS.include?(env) }
  end

  def check_environment_context?
    actual_environment.in?(allowed_environments)
  end
end
