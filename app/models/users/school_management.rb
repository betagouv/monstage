# frozen_string_literal: true

module Users
  # involve all adults in school. each are 'roled'
  #   school_manager (first registered, validated due to ac-xxx.fr email)
  #   main_teacher (track and help students in one class)
  #   teacher (any teacher can check & help students [they can choose class_room])
  #   other (involve psychologists, teacher assistants etc...)
  class SchoolManagement < User
    validates :first_name,
              :last_name,
              :role,
              presence: true

    belongs_to :school, optional: true
    belongs_to :class_room, optional: true
    has_many :students, through: :class_room
    has_many :main_teachers, through: :school

    validates :school, presence: true, on: :create
    validate :only_join_managed_school, on: :create, unless: :school_manager?
    validate :official_uai_email_address, on: :create, if: :school_manager?

    before_update :notify_school_manager, if: :notifiable?
    after_create :notify_school_manager, if: :notifiable?

    def self.i18n_roles
      roles.map do |ruby_role, _|
        OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
      end
    end

    def custom_dashboard_path
      return url_helpers.edit_dashboard_school_path(school) if school.present? && school.weeks.size.zero?
      return url_helpers.dashboard_school_class_room_path(school, class_room) if school.present? && class_room.present?
      return url_helpers.dashboard_school_class_rooms_path(school) if school.present?

      url_helpers.account_path
    end

    def custom_dashboard_paths
      [
        after_sign_in_path
      ]
    rescue ActionController::UrlGenerationError
      []
    end

    def dashboard_name
      return 'Ma classe' if school.present? && class_room.present?
      return 'Mon établissement' if school.present?
    end

    def new_support_ticket(params: {})
      SupportTickets::SchoolManager.new(params.merge(school_id: self.school_id, user_id: self.id))
    end

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
        errors.add(:email, "L'adresse email utilisée doit être l'adresse officielle de l'établissement. ex: ce.MON_CODE_UAI@ac-MON_ACADEMIE.fr")
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
