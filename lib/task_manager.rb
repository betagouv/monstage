require 'pretty_console'
module TaskManager
  def add_task
    if Rails.env in allowed_environments
      registration = TaskRegister.new(
        task_name: task_name,
        allowed_environment: Rails.env,
        played_at: Time.zone.now
      )
      registration.save!
    end
  end

  def play_task_once
    if already_played?
      message = "Task has been played once already at : " \
                "#{localize(played_at, format: :human_mm_dd_hh)}"
      PrettyConsole.puts_in_red(message)
    elsif wrong_environment_declaration?
      message = "L'environnement déclaré n'existe pas, il doit être pris " \
                " parmi development, staging, review, production"
      PrettyConsole.puts_in_red(message)
    else
      add_task
      # play_task
    end
  end


  def already_played?
    return true unless Rails.env in allowed_environments
    registration = TaskRegister.where(task_name: task_name)
                               .where(allowed_environment: Rails.env)
    registration.present?
  end

  attr_accessor :allowed_environments, :played_at, :task_name, :arguments

  private

  def initialize(allowed_environments:, task_name:, arguments:)
    @allowed_environments = allowed_environments
    @arguments = arguments
    @task_name = task_name
    @played_at = nil
  end

end