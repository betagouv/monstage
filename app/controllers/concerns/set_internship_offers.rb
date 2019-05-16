module SetInternshipOffers
  extend ActiveSupport::Concern

  included do
    def set_internship_offers
      @internship_offers = InternshipOffer.kept
                             .available_in_the_future
                             .for_user(user: current_user)
                             .page(params[:page])
    end
  end
end
