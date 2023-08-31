module SearchHelper
  def years_from_list_months_search
    return Date.today.year if list_months_for_search.blank?
    
    list_months = list_months_for_search.values.flatten
    year_start  = list_months.first.year
    year_end    = list_months.last.year
    year_start == year_end ? year_start : "#{year_start} - #{year_start + 1}"
  end

  def search_first_month?(month_i)
    month_i == list_months_for_search.keys.first
  end

  def search_last_month?(month_i)
    month_i == 5
  end

  def next_month(month_i)
    month_list = list_months_for_search.keys
    month_index = month_list.find_index(month_i)
    month_list[month_index + 1]
  end

  def previous_month(month_i)
    month_list = list_months_for_search.keys
    month_index = month_list.find_index(month_i)
    month_list[month_index - 1]
  end

  def month_in_text(month_i, opts)
    month_date = Date.new(Date.today.year, month_i, 1)
    I18n.localize(month_date, **opts).capitalize
  end

  def current_month_for_search
    default_month = list_months_for_search.keys.first
    list_months_include_current_month = list_months_for_search.keys
                                                      .include?(Date.today.month)
    list_months_include_current_month ?
      Date.today.month :
      default_month
  end

  def search_button_label
    count = params.permit(:latitude, :keyword, week_ids: [])
                  .to_h
                  .map do |k,v|
                    v&.empty? ? 0 : 1
                  end
                  .sum
    count.zero? ? 'Rechercher' : "Modifier ma recherche (#{count})"
  end

  def list_months_for_search
    months_map = {
      9 => [],
      10 => [],
      11 => [],
      12 => [],
      1 => [],
      2 => [],
      3 => [],
      4 => [],
      5 => [],
    }

    @_list_months_for_search ||= Week.selectable_from_now_until_end_of_school_year
      .inject(months_map.clone) do |months, week|
        week_date = week.week_date
        beginning_of_week = week_date.beginning_of_week

        months[beginning_of_week.month].push(week)
        months
      end
      .select{ |month_number, weeks|
        weeks.size.positive?
      }
  end
end
