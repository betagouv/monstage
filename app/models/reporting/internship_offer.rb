module Reporting
  class InternshipOffer < ApplicationRecord
    def self.table_name_prefix
    'reporting_'
    end
  end
end
