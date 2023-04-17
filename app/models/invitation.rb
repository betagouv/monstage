class Invitation < ApplicationRecord
  belongs_to :school_manager, -> { where(role: :school_manager) },
             class_name: 'Users::SchoolManagement',
             foreign_key: 'user_id'
  delegate :school, to: :school_manager

  enum role: {
    teacher: 'Professeur',
    main_teacher: 'Professeur principal',
    other: 'Autre'
  }

  validates :first_name,
            :last_name,
            :email,
            :role, presence: true
  validates_associated :school_manager
  validate  :official_email_address

  scope :not_registered_in, ->(school_id:) {
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
    return unless school_manager.present?
    return unless email.present?

    if email.split('@').second != school.email_domain_name
      errors.add(
        :email,
        "L'adresse email utilisée doit être officielle.<br>ex: XXXX@ac-academie.fr".html_safe
      )
    end
  end
end
