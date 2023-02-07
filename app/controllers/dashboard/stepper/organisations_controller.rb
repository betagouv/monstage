# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in company info
  class OrganisationsController < ApplicationController
    include ThreeFormsHelper
    before_action :authenticate_user!

    def index
      authorize! :index, Organisation
      current_process = params[:current_process]
      @title = set_title(current_process)
      # @edit = params[:internship_offer_id].present?
      # if @edit
      #   raise 'boom'
      #   @internship_offer_id = params[:internship_offer_id]
      #   @internship_offer     = InternshipOffer.find(@internship_offer_id)
      #   # internship_offer_tree = InternshipOfferTree.new(internship_offer: @internship_offer)
      #                                             #  .check_or_create_underlying_objects
      #   # Authorization step
      #   @organisation = internship_offer_tree.organisation
      # end
      params[:checked_organisations_list] = true
      @organisations = current_user.organisations.order(updated_at: :desc)
    end

    # render step 1
    def new
      authorize! :create, Organisation
      current_process = params[:current_process]
      @title = set_title(current_process)
      @internship_offer_id = params[:internship_offer_id]

      user_has_not_checked_list = params[:checked_organisations_list].nil?
      existing_organisations = current_user.organisations.count.positive?
      if existing_organisations && user_has_not_checked_list
        option = {}
        if @internship_offer_id.present?
          option = {
            internship_offer_id: @internship_offer_id,
            current_process: current_process
          }
        end
        redirect_to dashboard_stepper_organisations_path(option)
        return
      end
      @organisation = Organisation.new
      # @organisation = Organisation.new(organisation_params) if organisation_params&.present?
    end

    def create
      authorize! :create, Organisation
      if organisation_params[:siret].present?
        @organisation = Organisation.find_by(siret: organisation_params[:siret])
      end
      @organisation ||= Organisation.new(organisation_params.merge(db_interpolated: false))

      if @organisation.save
        notice = "Vos informations sont enregistrées"
        current_process = params[:organisation][:current_process]
        if current_process.blank?
          # internship_offer creation
          redirect_to new_dashboard_stepper_internship_offer_info_path(organisation_id: @organisation.id),
                      notice: notice
        elsif current_process == 'offer_update'
          internship_offer = InternshipOffer.find(params[:organisation][:internship_offer_id])
          internship_offer.update(organisation_id: @organisation.id)

          redirect_to edit_dashboard_internship_offer_path(
            internship_offer,
            internship_offer_id: params[:organisation][:internship_offer_id],
            organisation_id: @organisation.id,
            current_process: current_process,
            step: '2'), notice: notice
        end
      else
        render :new, status: :bad_request
      end
    end

    # TODO: edit/update. other back does not works. which is missing

    # render back to step 1
    def edit
      @current_process = params[:current_process]
      @title = set_title(@current_process)
      @organisation = Organisation.find(params[:id])
      authorize! :edit, @organisation
    end

    # process update following a back to step 1
    # or
    # by internship_offer update process
    def update
      @organisation = Organisation.find(params[:id])
      authorize! :update, @organisation

      parameters = organisation_params.merge!(db_interpolated: false)
      current_process = params[:organisation][:current_process]
      if current_process.blank?
        # internship_offer creation
        if @organisation.update(parameters)
          redirect_to new_dashboard_stepper_internship_offer_info_path(
            organisation_id: @organisation.id
          )
        else
          render :edit, status: :bad_request
        end
      elsif current_process == 'offer_update'
        # internship_offer edition
        update_button_label = 'Modifier'
        was_interpolated = @organisation.db_interpolated?
        @internship_offer = InternshipOffers::WeeklyFramed.find_by(organisation_id: @organisation.id)

        ActiveRecord::Base.transaction do
          if @organisation.update(parameters)
            # @internship_offer.update(organisation_id: @organisation.id)
            @internship_offer = offer_tree(@internship_offer).synchronize(@organisation)
            destination = edit_dashboard_internship_offer_path( @internship_offer, step: '1', current_process: current_process)
            redirect_to destination, notice: "Les modifications sont enregistrées.",
                                     data:{ turbo: false }
          else
            params[:step] = 1
            @available_weeks = @internship_offer.available_weeks
            render_when_error(update_button_label)
          end
        end
      end
    end

    private

    def organisation_params
      params.require(:organisation)
            .permit(
              :employer_name,
              :coordinates,
              :street,
              :zipcode,
              :city,
              :siret,
              :manual_enter,
              :employer_description_rich_text,
              :employer_website,
              :is_public,
              :group_id,
              :autocomplete,
              :db_interpolated,
              coordinates: {})
            .merge(employer_id: current_user.id)
    end

    # def notice(was_interpolated)
    #   notice = "Les modifications sont enregistrées."
    #   extended_notice = "#{notice} Les onglets 'Modifier le stage' et 'Modifier' " \
    #                     "le tuteur de stage' sont maintenant disponibles en haut de page"
    #   was_interpolated ? extended_notice : notice
    # end
  end
end
