module Reporting
  class InternshipOffer < ApplicationRecord
    include Yearable

    belongs_to :sector
    delegate :name, to: :sector, prefix: true

    AGGREGATE_FUNCTIONS = [
      "sum(total_applications_count) as total_applications_count",
      "sum(total_male_applications_count) as total_male_applications_count",
      "sum(total_applications_count) - sum(total_male_applications_count) as total_female_applications_count",
      "sum(convention_signed_applications_count) as convention_signed_applications_count",
      "sum(total_male_convention_signed_applications_count) as total_male_convention_signed_applications_count",
      "sum(convention_signed_applications_count) - sum(total_male_convention_signed_applications_count) as total_female_convention_signed_applications_count"
    ].freeze

    scope :by_departement, -> (department_name:) {
      where(department: department_name)
    }
    scope :by_group_name, -> (group_name:) {
      where(group_name: group_name)
    }
    scope :by_academy_name, -> (academy_name:) {
      where(academy: academy_name)
    }

    scope :grouped_by_sector, -> () {
      select("sector_id",
             "count(sector_id) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .includes(:sector)
        .group(:sector_id)
    }

    scope :grouped_by_publicy, -> () {
      select("is_public",
             "count(is_public) as report_total_count",
             *AGGREGATE_FUNCTIONS)
        .group(:is_public)
    }
  end
end
