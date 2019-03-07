class SchoolManager < User
  validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/

  belongs_to :school, optional: true

  def after_sign_in_path
    return account_path if resource.school.blank? || resource.school.weeks.empty?
  end
end
