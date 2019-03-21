module UserManageable
  extend ActiveSupport::Concern

  included do
    belongs_to :school
    has_one :school_manager, through: :school

    validates :first_name,
              :last_name,
              presence: true

    validates :school_manager, presence: true,
                               if: :school_id_changed?
    validates :school_manager, presence: true,
                               on: :create

    before_update :notify_school_manager, if: :school_id_changed?
    after_create :notify_school_manager

    def notify_school_manager
      SchoolManagerMailer.new_member(school_manager: school_manager,
                                     member: self)
                         .deliver_later
    end

  end
end
