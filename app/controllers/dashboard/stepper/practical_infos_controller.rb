# frozen_string_literal: true

module Dashboard::Stepper
  # Step 4 of internship offer creation: fill in Practical info
  class PracticalInfosController < ApplicationController
    before_action :authenticate_user!
    before_action :clean_params, only: [:create, :update]

    # render step 4
    def new
      authorize! :create, PracticalInfo

      @organisation = Organisation.find(params[:organisation_id])
      @practical_info = PracticalInfo.new(
        street: @organisation.street,
        zipcode: @organisation.zipcode,
        city: @organisation.city,
        coordinates: {
          latitude: @organisation.coordinates&.latitude,
          longitude: @organisation.coordinates&.longitude
        },
        contact_phone: current_user.try(:phone)
      )
      @hosting_info = HostingInfo.find(params[:hosting_info_id])
      @internship_offer_info = InternshipOfferInfo.find(params[:internship_offer_info_id])
    end

    # process step 4
    def create
      authorize! :create, PracticalInfo
      destroy_dupplicate!
      @practical_info = PracticalInfo.new(
        {}.merge(practical_info_params)
          .merge(employer_id: current_user.id)
      )
      @practical_info.save!
      internship_offer_builder.create_from_stepper(**builder_params) do |on|
        on.success do |created_internship_offer|
          redirect_to(internship_offer_path(created_internship_offer, origine: 'dashboard', stepper: true),
                      flash: { success: 'Votre offre de stage est prête à être publiée.' })
        end
        on.failure do |failed_internship_offer|
          render :new, status: :bad_request
        end
      end
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      @practical_info = PracticalInfo.new(
        contact_phone: @practical_info.contact_phone,
        lunch_break: @practical_info.lunch_break,
        weekly_hours: @practical_info.weekly_hours,
        daily_hours: @practical_info.daily_hours,
        street: @organisation.street,
        zipcode: @organisation.zipcode,
        city: @organisation.city,
        coordinates: {
          latitude: @organisation.coordinates&.latitude,
          longitude: @organisation.coordinates&.longitude
        }
      )
      @practical_info.employer = current_user
      @practical_info.valid?
      @hosting_info = HostingInfo.find(params[:hosting_info_id])
      @internship_offer_info = InternshipOfferInfo.find(params[:internship_offer_info_id])
      render :new, status: :bad_request
    end

    # render back to step 4
    def edit
      @practical_info = PracticalInfo.find(params[:id])
      @organisation = Organisation.find(params[:organisation_id])
      authorize! :edit, @practical_info
    end

    # process update following a back to step 3 (info was created, it's updated)
    def update
      @practical_info = PracticalInfo.find(params[:id])
      authorize! :update, @practical_info

      if @practical_info.update(practical_info_params)
        internship_offer = InternshipOffer.find_by(practical_info_id: @practical_info.id)
        if internship_offer.present?
          # update internship_offer from builder
          internship_offer_builder.update_from_stepper(internship_offer,
                                                        organisation: Organisation.find(params[:organisation_id]),
                                                        internship_offer_info: InternshipOfferInfo.find(params[:internship_offer_info_id]),
                                                        hosting_info: HostingInfo.find(params[:hosting_info_id]),
                                                        practical_info: @practical_info) do |on|
            on.success do |created_internship_offer|
              redirect_to(internship_offer_path(internship_offer, origine: 'dashboard'),
                        flash: { success: 'Votre offre de stage est prête à être publiée.' })
            end
            on.failure do |failed_internship_offer|
              @organisation = Organisation.find(params[:organisation_id])
              render :edit, status: :bad_request
            end
          end                            


        else
          redirect_to root_path, flash: { error: 'Erreur lors de la mise à jour de l\'offre de stage' }
        end
      else
        @organisation = Organisation.find(params[:organisation_id])
        render :new, status: :bad_request
      end
    end

    private

    def practical_info_params
      params.require(:practical_info)
            .permit(
              :id,
              :street,
              :zipcode,
              :city,
              :siret,
              :employer_id,
              :lunch_break,
              :contact_phone,
              weekly_hours: [],
              daily_hours: {},
              coordinates: {}
              )
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end

    def builder_params
      {
        organisation: Organisation.find(params[:organisation_id]),
        internship_offer_info: InternshipOfferInfo.find(params[:internship_offer_info_id]),
        hosting_info: HostingInfo.find(params[:hosting_info_id]),
        practical_info: @practical_info
      }
    end

    def destroy_dupplicate!
      internship_offer =  InternshipOffer.find_by(
        organisation_id: params[:organisation_id],
        internship_offer_info_id: params[:internship_offer_info_id],
        hosting_info_id: params[:hosting_info_id])
      internship_offer.destroy if internship_offer.present?
    end

    def clean_params
      params[:practical_info][:street] = [params[:practical_info][:street], params[:practical_info][:street_complement]].compact_blank.join(' - ') if params[:practical_info]
    end
  end
end
