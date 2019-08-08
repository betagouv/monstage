# frozen_string_literal: true

module Reporting
  class InternshipOffer < ApplicationRecord
    def readonly?
      true
    end

    belongs_to :sector
    delegate :name, to: :sector, prefix: true

    AGGREGATE_FUNCTIONS = {
      report_total_count: 'sum(max_internship_week_number * max_candidates)',
      total_applications_count: 'sum(total_applications_count)',
      total_male_applications_count: 'sum(total_male_applications_count)',
      total_female_applications_count: 'sum(total_applications_count) - sum(total_male_applications_count)',
      total_convention_signed_applications_count: 'sum(convention_signed_applications_count)',
      total_male_convention_signed_applications_count: 'sum(total_male_convention_signed_applications_count)',
      total_female_convention_signed_applications_count: 'sum(convention_signed_applications_count) - sum(total_male_convention_signed_applications_count)'
    }.freeze

    def self.aggregate_functions_to_sql_select
      AGGREGATE_FUNCTIONS.map do |attribute_name, group_function|
        "#{group_function} as #{attribute_name}"
      end
    end

    # what's the rails way?
    def self.i18n_attribute(attribute_name)
      I18n.t(
        [
          'activerecord',
          'attributes',
          'reporting/internship_offer',
          attribute_name
        ].join('.')
      )
    end

    def self.csv_headers(headers:{})
      AGGREGATE_FUNCTIONS.keys.inject(headers) do |headers, column_name|
        headers[column_name] = i18n_attribute(column_name)
        headers
      end
    end

    scope :during_current_year, lambda {
      during_year(year: Date.today.month <= SchoolYear::MONTH_OF_YEAR_SHIFT ? Date.today.year - 1 : Date.today.year)
    }

    # year parameter is the first year from a school year.
    # For example, year would be 2019 for school year 2019/2020
    scope :during_year, lambda { |year:|
      where('created_at > :date_begin', date_begin: Date.new(year, SchoolYear::MONTH_OF_YEAR_SHIFT, SchoolYear::DAY_OF_YEAR_SHIFT))
        .where('created_at <= :date_end', date_end: Date.new(year + 1, SchoolYear::MONTH_OF_YEAR_SHIFT, SchoolYear::DAY_OF_YEAR_SHIFT))
    }

    scope :by_department, lambda { |department:|
      where(department: department)
    }

    scope :by_group, lambda { |group:|
      where(group: group)
    }

    scope :by_academy, lambda { |academy:|
      where(academy: academy)
    }

    scope :grouped_by_sector, lambda {
      select('sector_id',
             *self.aggregate_functions_to_sql_select)
        .includes(:sector)
        .group(:sector_id)
        .order(:sector_id)
    }

    scope :grouped_by_publicy, lambda {
      select('is_public',
             *self.aggregate_functions_to_sql_select)
        .group(:is_public)
        .order(:is_public)
    }

    scope :grouped_by_group, lambda {
      select('internship_offers.group',
             *self.aggregate_functions_to_sql_select)
        .where(is_public: true)
        .group('internship_offers.group')
        .order('internship_offers.group')
    }

    scope :total_for_year, lambda {
      select(*self.aggregate_functions_to_sql_select)
        .during_year(year: Date.today.month <= SchoolYear::MONTH_OF_YEAR_SHIFT ? Date.today.year - 1 : Date.today.year)
        .group(:is_public)
    }

  end
end
