# frozen_string_literal: true

module Reporting
  # wrap reporting for internship offers
  class InternshipOffer < ApplicationRecord
    def readonly?
      true
    end

    belongs_to :sector
    belongs_to :group
    delegate :name, to: :group, prefix: true
    delegate :name, to: :sector, prefix: true

    # beware, order matters on csv export
    AGGREGATE_FUNCTIONS = {
      total_report_count: 'sum(max_candidates)',
      total_applications_count: 'sum(total_applications_count)',
      total_male_applications_count: 'sum(total_male_applications_count)',
      total_female_applications_count:
        'sum(total_applications_count)' \
        ' - ' \
        'sum(total_male_applications_count)',
      approved_applications_count:
        'sum(approved_applications_count)',
      total_custom_track_approved_applications_count:
        'sum(total_custom_track_approved_applications_count)',
      total_male_approved_applications_count:
        'sum(total_male_approved_applications_count)',
      total_female_approved_applications_count:
        'sum(approved_applications_count)' \
        ' - ' \
        'sum(total_male_approved_applications_count)'
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

    def self.csv_headers(headers: {})
      AGGREGATE_FUNCTIONS.keys
                         .each_with_object(headers) do |column_name|
        headers[column_name] = i18n_attribute(column_name)
      end
    end

    scope :during_current_year, lambda {
      during_year(year: if Date.today.month <= SchoolYear::Base::MONTH_OF_YEAR_SHIFT
                        then Date.today.year - 1
                        else Date.today.year
                        end)
    }

    # year parameter is the first year from a school year.
    # For example, year would be 2019 for school year 2019/2020
    scope :during_year, lambda { |year:|
      where('created_at > :date_begin',
            date_begin: Date.new(year,
                                 SchoolYear::Base::MONTH_OF_YEAR_SHIFT,
                                 SchoolYear::Base::DAY_OF_YEAR_SHIFT))
        .where('created_at <= :date_end',
               date_end: Date.new(year + 1,
                                  SchoolYear::Base::MONTH_OF_YEAR_SHIFT,
                                  SchoolYear::Base::DAY_OF_YEAR_SHIFT))
    }

    scope :by_department, lambda { |department:|
      where(department: department)
    }

    scope :by_academy, lambda { |academy:|
      where(academy: academy)
    }

    scope :dimension_by_sector, lambda {
      select('sector_id', *aggregate_functions_to_sql_select)
        .includes(:sector)
        .group(:sector_id)
        .order(:sector_id)
    }

    scope :dimension_by_group, lambda {
      select('group_id', *aggregate_functions_to_sql_select)
        .includes(:group)
        .group(:group_id)
        .order(:group_id)
    }

    scope :total_for_year, lambda {
      select(*aggregate_functions_to_sql_select)
        .during_year(
          year: if Date.today.month <= SchoolYear::Base::MONTH_OF_YEAR_SHIFT
                then Date.today.year - 1
                else Date.today.year
                end
        )
        .group(:is_public)
    }
  end
end
