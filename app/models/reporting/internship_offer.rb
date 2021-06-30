# frozen_string_literal: true

module Reporting
  # wrap reporting for internship offers
  class InternshipOffer < ApplicationRecord
    def readonly?
      true
    end

    self.inheritance_column = nil

    belongs_to :sector
    # belongs_to :organisation
    belongs_to :group, optional: true
    belongs_to :school, optional: true
    has_many :internship_offer_weeks
    has_many :weeks, through: :internship_offer_weeks
    has_many :internship_applications

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

    def self.during_year_predicate(school_year:)
      left =  InternshipOffer.arel_table[:daterange]
      right = Arel::Nodes::SqlLiteral.new(
        sprintf("daterange '[%s,%s)'", # see: https://www.postgresql.org/docs/13/rangetypes.html#RANGETYPES-IO
                school_year.beginning_of_period.strftime('%Y-%m-%d'), # use current year beginning for range opening
                school_year.next_year.beginning_of_period.strftime('%Y-%m-%d')) # use next year beginning for range ending
      )
      Arel::Nodes::InfixOperation.new('&&', left, right)
    end


    # year parameter is the first year from a school year.
    # For example, year would be 2019 for school year 2019/2020
    scope :during_year, lambda { |school_year:|
      where(Reporting::InternshipOffer.during_year_predicate(school_year: school_year))
    }

    scope :by_department, lambda { |department:|
      where(department: department)
    }

    scope :by_academy, lambda { |academy:|
      where(academy: academy)
    }

    scope :by_school_track, lambda { |school_track:|
      where(school_track: school_track)
    }

    scope :dimension_offer, lambda {
      select('internship_offers.*')
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

    scope :by_detailed_typology, lambda { |detailed_typology:|
      case detailed_typology
      when 'private'
        where(is_public: false)
      when 'paqte'
        where(is_public: false).where.not(group_id: nil)
      when 'public'
        where(is_public: true)
      else # all
        all
      end
    }
  end
end
