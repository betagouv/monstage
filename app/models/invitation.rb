class Invitation < ApplicationRecord
  belongs_to :author,
             class_name: 'Users::SchoolManagement',
             foreign_key: 'user_id'
  delegate :school, to: :author

  enum role: {
    teacher: 'Professeur',
    main_teacher: 'Professeur principal',
    other: 'Autre',
    cpe: 'CPE',
    admin_officer: 'Responsable administratif'
  }

  validates :first_name,
            :last_name,
            :email,
            :role, 
            :user_id, presence: true
             
  validate  :official_email_address

  scope :for_people_with_no_account_in, ->(school_id:) {
    where.not( email: Users::SchoolManagement.kept
                                             .where(school_id: school_id)
                                             .pluck(:email))
  }
  def presenter
    @presenter ||= Presenters::Invitation.new(self)
  end

  private

  # validators
  def official_email_address
    return unless email.present?

    if email.split('@').second != school.email_domain_name
      errors.add(
        :email,
        "L'adresse email utilisée doit être officielle.<br>ex: XXXX@ac-academie.fr".html_safe
      )
    end
  end
end
