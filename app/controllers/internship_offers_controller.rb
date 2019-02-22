class InternshipOffersController < ApplicationController
  def index
    @internship_offers = InternshipOffer.kept
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def create
    authorize! :create, InternshipOffer
    @internship_offer = InternshipOffer.new(internship_offer_params)
    @internship_offer.save!
    redirect_to(internship_offer_path(@internship_offer),
                flash: {success: 'Votre annonce a bien été créée'}
  rescue ActiveRecord::RecordInvalid,
         ActionController::ParameterMissing
    @internship_offer ||= InternshipOffer.new
    find_selectable_content
    render 'internship_offers/new', status: :bad_request
  rescue CanCan::AccessDenied
    redirect_to(internship_offers_path,
                flash: { danger: "Vous n'êtes pas autorisé à poster une annonce" })
  end

  def edit
    authorize! :edit, InternshipOffer
    @internship_offer = InternshipOffer.find(params[:id])
    find_selectable_content
  rescue CanCan::AccessDenied
    redirect_to(internship_offers_path,
                flash: { danger: "Vous n'êtes pas autorisé à modifier une annonce" })
  end

  def update
    authorize! :manage, InternshipOffer
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.update!(internship_offer_params)

    redirect_to(@internship_offer,
                flash: { success: 'Votre annonce a bien été modifiée'})
  rescue ActiveRecord::RecordInvalid,
         ActionController::ParameterMissing => error
    find_selectable_content
    render :edit, status: :bad_request
  rescue CanCan::AccessDenied,
    redirect_to(internship_offers_path,
                flash: { danger: "Vous n'êtes pas autorisé à modifier une annonce" })
  end

  def destroy
    authorize! :update, InternshipOffer
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.discard
    redirect_to(root_path,
                flash: { success: 'Votre annonce a bien été supprimée' })
  rescue CanCan::AccessDenied
    redirect_to(internship_offers_path,
                flash: { danger: "Vous n'êtes pas autorisé à supprimer leurs annonces" })
  end

  def new
    authorize! :update, InternshipOffer
    @internship_offer = InternshipOffer.new
    find_selectable_content
  rescue CanCan::AccessDenied
    redirect_to(internship_offers_path,
                flash: { danger: "Vous n'êtes pas autorisé à créer une annonce" })
  end

  private

  def find_selectable_weeks
    today = Date.today
    current_year = today.year
    current_month = today.month

    if current_month < 5 # Before May, offers should be available from now until May of the current year
      @current_weeks = Week.from_date_to_date_for_year(today, Date.new(current_year, 5, 1), current_year)
    else # After May, offers should be posted for next year
      first_day_available = if current_month < 9 # Between May and September, the first week should be the first week of september
                              Date.new(current_year, 9, 1)
                            else
                              today
                            end
      @current_weeks = Week.from_date_until_end_of_year(first_day_available, current_year)
                           .or(Week.from_date_to_date_for_year(Date.new(current_year + 1), Date.new(current_year + 1, 5, 1), current_year + 1))
    end
  end

  def find_selectable_operators
    @operators = User.where.not(operator_name: nil)
  end

  def find_selectable_content
    find_selectable_weeks
    find_selectable_operators
  end

  def internship_offer_params
    params.require(:internship_offer)
        .permit(:title, :description, :sector, :can_be_applied_for, :week_day_start, :week_day_end, :excluded_weeks,
                :max_candidates, :max_weeks, :tutor_name, :tutor_phone, :tutor_email, :employer_website,
                :employer_description, :employer_street, :employer_zipcode, :employer_city, :supervisor_email, :is_public,
                :operator_id, week_ids: [])
  end
end
