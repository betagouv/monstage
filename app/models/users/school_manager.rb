module Users
  class SchoolManager < User
    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/
    belongs_to :school, optional: true
    has_many :main_teachers, through: :school

    include NearbyInternshipOffersQueryable

    def after_sign_in_path
      return Rails.application.routes.url_helpers.account_path if school.blank? || school.weeks.empty?
    end
  end
end
