# frozen_string_literal: true

module FormatableWeek
  extend ActiveSupport::Concern

  included do
    # to, strip, join with space otherwise multiple spaces can be outputted,
    # then within html it is concatenated [html logic], but capybara fails to find this content
    def short_select_text_method
      ['du', beginning_of_week, 'au', end_of_week]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def short_range_as_str
      [
        I18n.localize(week_date.beginning_of_week, format: "%e %B"),
        " ➝ ",
        I18n.localize(week_date.end_of_week, format: "%e %B")
      ].join("")
    end

    alias_method :to_s, :short_range_as_str

    def long_select_text_method
      ['du', beginning_of_week_with_year, 'au', end_of_week_with_years]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def very_long_select_text_method
      ['du', beginning_of_week_with_year_long, 'au', end_of_week_with_years_long]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def human_select_text_method
      ['Semaine du', beginning_of_week, 'au', end_of_week]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def select_text_method
      ['Du', beginning_of_week_with_short_month_year_long, 'au', end_of_week_with_short_month_years_long, "[Sem - #{number}]"]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def week_date
      Date.commercial(year, number)
    end

    def beginning_of_week
      I18n.localize(week_date.beginning_of_week, format: :human_mm_dd)
    end

    def beginning_of_week_with_year
      I18n.localize(week_date.beginning_of_week, format: :default)
    end

    def beginning_of_week_with_year_long
      I18n.localize(week_date.beginning_of_week, format: :human_mm_dd_yyyy)
    end

    def beginning_of_week_with_short_month_year_long
      I18n.localize(week_date.beginning_of_week, format: :human_dd_short_mm_yyyy)
    end

    def end_of_week
      I18n.localize(week_date.end_of_week, format: :human_mm_dd)
    end

    def end_of_week_with_years
      I18n.localize(week_date.end_of_week, format: :default)
    end

    def end_of_week_with_years_long
      I18n.localize(week_date.end_of_week, format: :human_mm_dd_yyyy)
    end

    def end_of_week_with_short_month_years_long
      I18n.localize(week_date.end_of_week, format: :human_dd_short_mm_yyyy)
    end
  end
end
