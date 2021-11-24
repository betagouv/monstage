module Zipcodable
  extend ActiveSupport::Concern

  included do
    validates :zipcode, presence: true
    validate :reverse_department_by_zipcode
    before_save :ensure_good_zipcode,
                :reverse_department_by_zipcode

    def ensure_good_zipcode
      self.zipcode = zipcode.ljust(5, '0')
    end

    def reverse_department_by_zipcode
      return false if zipcode.blank?

      department = Department.lookup_by_zipcode(zipcode: zipcode)
      if department.nil?
        errors.add(:zipcode, 'le code postal ne permet pas de déduire le département')
        return false
      end
      self.department = department
    end
  end
end
