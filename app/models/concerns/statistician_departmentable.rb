# frozen_string_literal: true

module StatisticianDepartmentable
  extend ActiveSupport::Concern

  included do
    # validates :email_whitelist, presence: { message: 'none' }
    validates :department, presence: true
    
    def dashboard_name
      'Statistiques'
    end

    #not commun
    # def department
    #   return '' if department_zipcode.blank?

    #   Department.lookup_by_zipcode(zipcode: department_zipcode)
    # end

    def department_name
      Department::MAP[department]
    end

    def department_zipcode
      # email_whitelist&.zipcode
      department
    end

    def destroy
      email_whitelist&.delete
      super
    end

    def employer_like? ; true end
  end
end
