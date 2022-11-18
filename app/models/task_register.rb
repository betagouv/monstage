class TaskRegister < ApplicationRecord
  validates :allowed_environment, presence: true
  # validates :allowed_environment, in: %w[development staging review production]

  
end
