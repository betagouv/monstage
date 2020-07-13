# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]
  before_action :flash_message_when_missing_school_weeks, only: :index

  with_options only: :show do
    before_action :set_internship_offer,
                  :check_internship_offer_is_not_discarded_or_redirect,
                  :check_internship_offer_is_published_or_redirect

    after_action :increment_internship_offer_view_count
  end

  def index
    @internship_offers = finder.all.order(id: :desc)
  end

  def show
    @previous_internship_offer = finder.next_from(from: @internship_offer)
    @next_internship_offer = finder.previous_from(from: @internship_offer)

    if current_user
      @internship_application = @internship_offer.internship_applications
                                                 .where(user_id: current_user_id)
                                                 .first
    end
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.with_rich_text_description_rich_text
                                       .with_rich_text_employer_description_rich_text
                                       .find(params[:id])
  end

  def flash_message_when_missing_school_weeks
    return unless current_user_or_visitor.missing_school_weeks?

    flash.now[:warning] = "Attention, votre établissement n'a pas encore renseigné ses dates de stages. Nous affichons des offres qui pourraient ne pas correspondre à vos dates."
  end

  def check_internship_offer_is_not_discarded_or_redirect
    return unless @internship_offer.discarded?

    redirect_to(user_presenter.default_internship_offers_path, flash: { warning: "Cette offre a été supprimée et n'est donc plus accessible" })
  end

  def check_internship_offer_is_published_or_redirect
    return if can?(:create, @internship_offer)
    return if @internship_offer.published?

    redirect_to(user_presenter.default_internship_offers_path, flash: { warning: "Cette offre n'est plus disponible" })
  end

  def current_user_id
    current_user.try(:id)
  end

  def finder
    @finder ||= Finders::ListableInternshipOffer.new(
      params: params.permit(
        :page,
        :latitude,
        :longitude,
        :radius,
        :keyword,
        :middle_school,
        :high_school
      ),
      user: current_user_or_visitor
    )
  end

  def increment_internship_offer_view_count
    if current_user.is_a?(Users::Student)
      @internship_offer.increment!(:view_count)
    end
  end
end
