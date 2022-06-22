# frozen_string_literal: true

module Users
  # involve all adults in school. each are 'roled'
  #   school_manager (first registered, validated due to ac-xxx.fr email)
  #   main_teacher (track and help students in one class)
  #   teacher (any teacher can check & help students [they can choose class_room])
  #   other (involve psychologists, teacher assistants etc...)
  class SchoolManagement < User
    include SchoolManagementAdmin
    include Signaturable

    validates :first_name,
              :last_name,
              :role,
              presence: true

    belongs_to :school, optional: true
    belongs_to :class_room, optional: true
    has_many :students, through: :school
    has_many :main_teachers, through: :school
    has_many :internship_applications, through: :students
    has_many :internship_agreements, through: :internship_applications

    validates :school, presence: true, on: :create
    validate :only_join_managed_school, on: :create, unless: :school_manager?
    validate :official_uai_email_address, on: :create, if: :school_manager?
    validate :official_email_address, on: :create

    before_update :notify_school_manager, if: :notifiable?
    after_create :notify_school_manager, if: :notifiable?

    def self.i18n_roles
      roles.map do |ruby_role, _|
        OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
      end
    end

    def custom_dashboard_path
      if school.present?
        return url_helpers.edit_dashboard_school_path(school) if school.weeks.size.zero?
        return url_helpers.dashboard_school_class_room_students_path(school, class_room) if induced_teacher?
        return url_helpers.dashboard_school_path(school)
      end

      url_helpers.account_path
    end

    def custom_dashboard_paths
      [
        after_sign_in_path
      ]
    rescue ActionController::UrlGenerationError
      []
    end

    # class_room testing induce role
    def induced_teacher?
      class_room.present?
    end

    def dashboard_name
      return 'Ma classe' if school.present? && induced_teacher?
      return 'Mon établissement' if school.present?

      ""
    end

    def new_support_ticket(params: {})
      SupportTickets::SchoolManager.new(params.merge(school_id: self.school_id, user_id: self.id))
    end

    def custom_agreements_path
      url_helpers.dashboard_internship_agreements_path
    end

    def role_presenter
      Presenters::UserManagementRole.new(user: self)
    end
    alias :presenter :role_presenter

    def signatory_role
      Signature.signatory_roles[:school_manager] if role == 'school_manager'
    end

    def already_signed?(internship_agreement_id:)
      return false unless role == 'school_manager'

      internship_agreement = InternshipAgreement.joins(:signatures)
                                                .where(id: internship_agreement_id)
                                                .where(signatures: {signatory_role: signatory_role})
      internship_agreement.any? &&
        internship_agreement.first
                            .try(:student)
                            .try(:school)
                            .try(:school_manager)
                            .try(:id) == id
    end

    def school_management? ; true end
    def school_manager? ; role == 'school_manager' end

    private

    # validators
    def only_join_managed_school
      unless school.try(:school_manager).try(:present?)
        errors.add(:base, "Le chef d'établissement ne s'est pas encore inscrit, il doit s'inscrire pour confirmer les professeurs principaux.")
      end
    end

    def official_email_address
      return if school_id.blank?
      unless email =~ /\A[^@\s]+@#{school.email_domain_name}\z/
        errors.add(
          :email,
          "L'adresse email utilisée doit être officielle.<br>ex: XXXX@ac-academie.fr".html_safe
        )
      end
    end

    def official_uai_email_address
      return if school_id.blank?

      unless email =~ /\Ace\.\d{7}\S@#{school.email_domain_name}\z/
        errors.add(:email, "L'adresse email utilisée doit être l'adresse officielle de l'établissement.<br>ex: ce.MON_CODE_UAI@ac-MON_ACADEMIE.fr".html_safe)
      end
    end

    # notify
    def notifiable?
      school_id_changed? && school_id? && !school_manager?
    end

    def notify_school_manager
      if school.school_manager.present?
        SchoolManagerMailer.new_member(school_manager: school.school_manager,
                                       member: self)
                           .deliver_later
      end
    end
  end
end
