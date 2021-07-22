module SearchHelper

  def month_in_text(month_i)
    month_date = Date.new(Date.today.year, month_i.to_i, 1)
    I18n.localize(month_date, format: :month_with_year).capitalize
  end

  def current_month_for_search
    default_month = list_months_for_search.keys.first.to_i
    list_months_include_current_month = list_months_for_search.keys
                                                      .map(&:to_i)
                                                      .include?(Date.today.month)
    list_months_include_current_month ?
      Date.today.month :
      default_month
  end

  def list_months_for_search
    months_map = {
      '9' => [],
      '10' => [],
      '11' => [],
      '12' => [],
      '1' => [],
      '2' => [],
      '3' => [],
      '4' => [],
      '5' => [],
      '6' => [],
    }

    @_list_months_for_search ||= Week.selectable_from_now_until_end_of_school_year
      .inject(months_map.clone) do |months, week|
        week_date = week.week_date
        beginning_of_week = week_date.beginning_of_week
        # end_of_week = week_date.end_of_week

        months[beginning_of_week.month.to_s].push(week)
        # months[end_of_week.month.to_s].push(week) if beginning_of_week.month != end_of_week.month
        months
      end
  end
end
