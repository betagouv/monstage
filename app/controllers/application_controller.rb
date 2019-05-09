class ApplicationController < ActionController::Base
  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || resource.after_sign_in_path || super
  end

  protected

  MONTH_OF_YEAR_SHIFT = 5
  DAY_OF_YEAR_SHIFT = 31

  def find_selectable_weeks
    today = Date.today
    current_year = today.year
    current_month = today.month

    if current_month <= MONTH_OF_YEAR_SHIFT # Before the end of May, offers should be available from now until May of the current year
      @current_weeks = Week.from_date_to_date_for_year(today, Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT), current_year)
    else # After May, offers should be posted for next year
      first_day_available = if current_month < 9 # Between May and September, the first week should be the first week of september
                              Date.new(current_year, 9, 1)
                            else
                              today
                            end
      @current_weeks = Week.from_date_until_end_of_year(first_day_available, current_year)
                           .or(Week.from_date_to_date_for_year(Date.new(current_year + 1), Date.new(current_year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT), current_year + 1))
    end
  end
end
