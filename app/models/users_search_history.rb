class UsersSearchHistory < ActiveRecord::Base
  # validations
  validates :user_id, presence: true

  # relations
  belongs_to :user
end