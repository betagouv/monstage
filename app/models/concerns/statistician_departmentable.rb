# frozen_string_literal: true

module StatisticianDepartmentable
  extend ActiveSupport::Concern

  included do
    validates :email_whitelist, presence: { message: 'none' }

    def dashboard_name
      'Statistiques'
    end

    #not commun
    def department
      return '' if department_zipcode.blank?

      Department.lookup_by_zipcode(zipcode: department_zipcode)
    end

    def department_zipcode
      email_whitelist&.zipcode
    end

    def destroy
      email_whitelist&.delete
      super
    end
  end
end
