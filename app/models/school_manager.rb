class SchoolManager < User
  validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/
  belongs_to :school, optional: true
  include NearbyIntershipOffersQueryable

  def after_sign_in_path
    return Rails.application.routes.url_helpers.account_edit_path if school.blank? || school.weeks.empty?
  end
end
