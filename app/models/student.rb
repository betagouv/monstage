class Student < User
  belongs_to :school, optional: true
end
