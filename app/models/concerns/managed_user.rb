# frozen_string_literal: true

module ManagedUser
  extend ActiveSupport::Concern

  included do
    belongs_to :school, optional: true
    has_one :school_manager, through: :school

    validates :first_name,
              :last_name,
              presence: true
    validates :school, presence: true, on: :create

    validates :school_manager, presence: true,
                               on: :create

    before_update :notify_school_manager, if: :notifiable?
    after_create :notify_school_manager

    def notifiable?
      school_id_changed? && school_id?
    end

    def notify_school_manager
      if school_manager.present?
        SchoolManagerMailer.new_member(school_manager: school_manager,
                                       member: self)
                           .deliver_later
      end
    end
  end
end
