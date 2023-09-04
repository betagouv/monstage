class DateRange

  MONTHS = %w(janvier février mars avril mai juin juillet août septembre octobre novembre décembre)

  def boundaries_as_string
    "du #{start_str} au #{end_str}"
  end

  private

  attr_reader :weeks,
              :day_week_start,
              :day_week_end,
              :day_week_start_nr,
              :day_week_end_nr,
              :month_week_start,
              :month_week_end,
              :year_week_start,
              :year_week_end

  def initialize(weeks:)
    @weeks             = weeks
    @first_week, @last_week = @weeks.minmax_by(&:id)
    @day_week_start    = @first_week.week_date
    @day_week_end      = (Week::WEEK_DURATION - 1).days.since(@last_week.week_date)
    @day_week_start_nr = @day_week_start.day
    @day_week_end_nr   = @day_week_end.day
    @month_week_start  = @day_week_start.month
    @month_week_end    = @day_week_end.month
    @year_week_start   = @day_week_start.year
    @year_week_end     = @day_week_end.year
  end

  def start_str
    if same_month && same_year
      day_week_start_nr
    elsif same_year
      "#{day_week_start_nr} #{month_as_string month_week_start}"
    else
      "#{day_week_start_nr} #{month_as_string month_week_start} #{year_week_start}"
    end
  end

  def end_str
    "#{day_week_end_nr} #{month_as_string month_week_end} #{year_week_end}"
  end

  def month_as_string(month)
    MONTHS[month - 1]
  end

  def same_month
    month_week_start == month_week_end
  end

  def same_year
    year_week_start == year_week_end
  end
end