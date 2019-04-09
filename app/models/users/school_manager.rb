module Users
  class SchoolManager < User
    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/
    belongs_to :school, optional: true
    has_many :main_teachers, through: :school

    include TargetableInternshipOffersForSchool

    def after_sign_in_path
      return url_helpers.account_path if school.blank? || school.weeks.empty?
      super
    end

    def custom_dashboard_path
      url_helpers.dashboard_school_path(school)
    rescue
      url_helpers.account_path
    end
  end
end
