module WeekHelper
  def week_select_option_display(week)
    week_date = Date.commercial(week.year, week.week)
    date_format = '%d/%m/%y'
    "Semaine #{week.week} - du #{week_date.beginning_of_week.strftime(date_format)} au #{week_date.end_of_week.strftime(date_format)}"
  end
end