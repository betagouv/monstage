class TaskRegister < ApplicationRecord
  # make TaskRegister an ActiveRecord
  ALLOWED_ENVIRONMENTS = %w[development test review staging production]
  validates :task_name, presence: true
  validates :used_environment, presence: true,
                               inclusion: {in: ALLOWED_ENVIRONMENTS}



  def self.find(task_name:, allowed_environment:)
    where(task_name: task_name)
      .where(allowed_environment: allowed_environment)
      .first
  end

end
