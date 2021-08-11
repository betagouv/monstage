# frozen_string_literal: true

module Presenters
  # render a lit of week easily with folding of internval
  class WeekList
    def to_range_as_str
      to_range do |is_first:, is_last:, week:|
        if is_first
          week.beginning_of_week_with_year_long
        elsif is_last
          week.end_of_week_with_years_long
        else
          week.very_long_select_text_method
        end
      end
    end

    def to_range(&block)
      case weeks.size
      when 0
        ''
      when 1
        render_first_week_only(&block)
      else
        render_by_collapsing_date_from_first_to_last_week(&block)
      end
    end

    def split_weeks_in_trunks
      week_list, container = [weeks.dup.to_a, []]
      while week_list.present?
        joined_weeks = [week_list.slice!(0)]
        while week_list.present? && week_list.first.consecutive_to?(joined_weeks.last)
          joined_weeks << week_list.slice!(0)
        end
        container << self.class.new(weeks: joined_weeks)
      end
      container
    end

    def student_compatible_week_list(student)
      self.class.new(weeks: weeks & student.school.weeks)
    end

    def to_s
      weeks.map(&:long_select_text_method)
           .join("\n")
    end

    def empty?
      weeks.empty?
    end

    def split_range_string
      to_range_as_str.split(/(\d*\s?semaines?\s?:?)/)
    end

    protected

    def render_first_week_only
      [
        'Disponible la semaine',
        yield(is_first: false, is_last: false, week: first_week)
      ].join(' ')
    end

    def render_by_collapsing_date_from_first_to_last_week
      [
        "Disponible sur #{weeks.size} semaines :",
        yield(is_first: true, is_last: false, week: first_week).to_s,
        " → #{yield(is_first: false, is_last: true, week: last_week)}"
      ].join(' ')
    end

    private

    attr_reader :weeks, :first_week, :last_week

    def initialize(weeks:)
      @weeks = weeks
      @first_week, @last_week = weeks.minmax_by(&:id)
    end

  end
end
