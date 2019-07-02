# frozen_string_literal: true

module Reporting
  class InternshipOffer < ApplicationRecord
    def readonly?
      true
    end

    belongs_to :sector
    delegate :name, to: :sector, prefix: true

    AGGREGATE_FUNCTIONS = {
      total_applications_count: 'sum(total_applications_count)',
      total_male_applications_count: 'sum(total_male_applications_count)',
      total_female_applications_count: 'sum(total_applications_count) - sum(total_male_applications_count)',
      total_convention_signed_applications_count: 'sum(convention_signed_applications_count)',
      total_male_convention_signed_applications_count: 'sum(total_male_convention_signed_applications_count)',
      total_female_convention_signed_applications_count: 'sum(convention_signed_applications_count) - sum(total_male_convention_signed_applications_count)'
    }.freeze

    def self.aggregate_functions_to_SQL
      AGGREGATE_FUNCTIONS.map do |attribute_name, group_function|
        "#{group_function} as #{attribute_name}"
      end
    end

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
      headers = headers.merge({ report_total_count: i18n_attribute(:report_total_count) })
      AGGREGATE_FUNCTIONS.keys.inject(headers) do |headers, column_name|
        headers[column_name] = i18n_attribute(column_name)
        headers
      end
      headers
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
             'sum(max_internship_week_number * max_candidates) as report_total_count',
             *self.aggregate_functions_to_SQL)
        .includes(:sector)
        .group(:sector_id)
        .order(:sector_id)
    }

    scope :grouped_by_publicy, lambda {
      select('is_public',
             'sum(max_internship_week_number * max_candidates) as report_total_count',
             *self.aggregate_functions_to_SQL)
        .group(:is_public)
        .order(:is_public)
    }

    scope :grouped_by_group, lambda {
      select('internship_offers.group',
             'sum(max_internship_week_number * max_candidates) as report_total_count',
             *self.aggregate_functions_to_SQL)
        .where(is_public: true)
        .group('internship_offers.group')
        .order('internship_offers.group')
    }



  end
end
