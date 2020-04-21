module Zipcodable
  extend ActiveSupport::Concern

  included do
    validates :zipcode, presence: true
    before_save :ensure_good_zipcode,
                :reverse_department_by_zipcode

    def ensure_good_zipcode
      self.zipcode = zipcode.ljust(5, '0')
    end

    def reverse_department_by_zipcode
      self.department = Department.lookup_by_zipcode(zipcode: zipcode)
    end
  end
end
