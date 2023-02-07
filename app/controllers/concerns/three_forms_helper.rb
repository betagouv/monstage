module ThreeFormsHelper
  extend ActiveSupport::Concern

  included do
    def render_when_error(update_button_label)
        error_edit_path = :edit
        error_new_path = :new
        error_dest = params[:commit] == update_button_label ? error_edit_path : error_new_path
        render error_dest, status: :bad_request
    end

    def offer_tree(internship_offer)
      InternshipOfferTree.new(internship_offer: internship_offer)
    end

    # TODO : move this to controller concerns
    def set_title(current_process)
      case current_process
      when "offer_update"
        "Modifier une offre de stage"
      when "offer_duplicate"
        "Dupliquer une offre de stage"
      else
        "Déposer une offre de stage"
      end
    end
  end
end