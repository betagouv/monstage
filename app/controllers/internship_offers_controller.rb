class InternshipOffersController < ApplicationController

  def index
    @internship_offers = InternshipOffer.kept
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def create
    @internship_offer = InternshipOffer.create(internship_offer_params)

    redirect_to internship_offer_path(@internship_offer)
  end

  def edit
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def update
    @internship_offer = InternshipOffer.find(params[:id])

    if @internship_offer.update(internship_offer_params)
      redirect_to @internship_offer
    else
      render :edit
    end
  end

  def destroy
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.discard

    redirect_to root_path
  end

  def new
    @internship_offer = InternshipOffer.new

    today = Date.today
    current_year = today.year
    current_month = today.month

    if current_month < 5 # Before May, offers should be available from now until May of the current year
      @current_weeks = Week.from_date_to_date_for_year(today, Date.new(current_year, 5, 1), current_year)
      @school_year = "#{current_year - 1} / #{current_year}"
    else # After May, offers should be posted for next year
      first_day_available = if current_month < 9 # Between May and September, the first week should be the first week of september
                              Date.new(current_year, 9, 1)
                            else
                              today
                            end
      @current_weeks = Week.from_date_until_end_of_year(first_day_available, current_year)
                           .or(Week.from_date_to_date_for_year( Date.new(current_year + 1), Date.new(current_year+1, 5, 1), current_year+1))
      @school_year = "#{current_year} / #{current_year + 1}"
    end
  end

  private

  def internship_offer_params
    params.require(:internship_offer)
        .permit(:title, :description, :sector, :can_be_applied_for, :week_day_start, :week_day_end, :excluded_weeks,
                :max_candidates, :max_weeks, :tutor_name, :tutor_phone, :tutor_email, :employer_website,
                :employer_description, :employer_street, :employer_zipcode, :employer_city, :supervisor_email, :is_public,
                week_ids: [])
  end
end
