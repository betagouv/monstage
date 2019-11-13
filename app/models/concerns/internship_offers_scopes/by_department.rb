# frozen_string_literal: true

module InternshipOffersScopes
  # find internships which had been bound by operators relationship
  # InternshipOffer.where(employer_id: user.id)
  module ByDepartment
    extend ActiveSupport::Concern

    included do
      scope :limited_to_department, lambda { |user:|
        InternshipOffer.where(department: user.department_name)
      }
    end
  end
end
