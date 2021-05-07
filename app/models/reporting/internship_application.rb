# frozen_string_literal: true
#Reporting::
module Reporting
  # wrap reporting for internship offers
  class InternshipApplication < ApplicationRecord
    def readonly?
      true
    end
    self.inheritance_column = nil
    belongs_to :internship_offer

  end
end
