module Reporting
  class InternshipOffer < ApplicationRecord
    include Yearable

    def self.refresh
      Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
    end

    AGGREGATE_FUNCTIONS = [
      "sum(total_applications_count) as total_applications_count",
      "sum(total_male_applications_count) as total_male_applications_count",
      "sum(total_applications_count) - sum(total_male_applications_count) as total_female_applications_count",
      "sum(convention_signed_applications_count) as convention_signed_applications_count",
      "sum(total_male_convention_signed_applications_count) as total_male_convention_signed_applications_count",
      "sum(convention_signed_applications_count) - sum(total_male_convention_signed_applications_count) as total_female_convention_signed_applications_count"
    ].freeze

    scope :by_departement, -> (department_name:) {
      where(department_name: department_name)
    }
    scope :by_group_name, -> (group_name:) {
      where(group_name: group_name)
    }
    scope :by_academy_name, -> (academy_name:) {
      where(academy: academy_name)
    }

    scope :grouped_by_sector, -> () {
      select("sector_name as report_row_title",
             "count(sector_name) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .group(:sector_name)
        .order(sector_name: :asc)
    }

    scope :grouped_by_publicy, -> () {
      select("publicly_name as report_row_title",
             "count(publicly_name) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .group(:publicly_name)
        .order(publicly_name: :asc)
    }

    def self.table_name_prefix
    'reporting_'
    end
  end
end
