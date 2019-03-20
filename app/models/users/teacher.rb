module Users
  class Teacher < User
    belongs_to :school
  end
end
