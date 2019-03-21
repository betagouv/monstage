module Users
  class SchoolManager < User
    validates :email, format: /\A[^@\s]+@ac-[^@\s]+\z/
    has_one :school
    has_many :main_teachers, through: :school

    before_save :replicate_school_id

    include NearbyIntershipOffersQueryable

    def replicate_school_id
      return unless school_id_changed?
      School.where(id: school_id)
            .update(school_manager_id: id)
    end

    def after_sign_in_path
      return Rails.application.routes.url_helpers.account_path if school.blank? || school.weeks.empty?
    end
  end
end
