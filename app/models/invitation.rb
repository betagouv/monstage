class Invitation < ApplicationRecord
  belongs_to :school_manager, -> { where(role: :school_manager) },
             class_name: 'Users::SchoolManagement', foreign_key: 'user_id'

  enum role: {
    teacher: 'Professeur',
    main_teacher: 'Professeur principal',
    other: 'Autre'
  }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validate  :official_email_address


  private

  # validators
  def official_email_address
    return if school_manager.school.blank? || school_manager.email.nil?

    unless self.email.split('@').second == school_manager.school.email_domain_name
      errors.add(
        :email,
        "L'adresse email utilisée doit être officielle.<br>ex: XXXX@ac-academie.fr".html_safe
      )
    end
  end
end
