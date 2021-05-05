# frozen_string_literal: true

module Reporting
  # wrap reporting for internship offers
  class InternshipApplication < ApplicationRecord
    def readonly?
      true
    end
    self.inheritance_column = nil
    belongs_to :internship_offer

    scope :partition_by_month, lambda {
      query = select("DATE_TRUNC('month',approved_at) AS  approved_at_to_month, sum(max_candidates) AS count")
      query = query.group("DATE_TRUNC('month',approved_at)")
      query.order("approved_at_to_month")
    }
  end
end
