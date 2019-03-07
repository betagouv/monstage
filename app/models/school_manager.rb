class SchoolManager < User
  validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/

  belongs_to :school
end