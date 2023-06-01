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
        }
      )
      
      @hosting_info = HostingInfo.find(params[:hosting_info_id])
      @internship_offer_info = InternshipOfferInfo.find(params[:internship_offer_info_id])
    end

    # process step 4
    def create
      authorize! :create, PracticalInfo
      @practical_info = PracticalInfo.new(
        {}.merge(practical_info_params)
          .merge(employer_id: current_user.id)
      )
      @practical_info.save!
      internship_offer_builder.create_from_stepper(builder_params) do |on|
        on.success do |created_internship_offer|
          redirect_to(internship_offer_path(created_internship_offer, origine: 'dashboard'),
                      flash: { success: 'Votre offre de stage est prête à être publiée.' })
        end
        on.failure do |failed_internship_offer|
          render :new, status: :bad_request
        end
      end
    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      @practical_info = PracticalInfo.new(
        street: @organisation.street,
        zipcode: @organisation.zipcode,
        city: @organisation.city,
        coordinates: {
          latitude: @organisation.coordinates&.latitude,
          longitude: @organisation.coordinates&.longitude
        }
      )
      
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
        internship_offer_builder.create_from_stepper(builder_params) do |on|
          on.success do |created_internship_offer|
            redirect_to(internship_offer_path(created_internship_offer, origine: 'dashboard'),
                        flash: { success: 'Votre offre de stage est prête à être publiée.' })
          end
          on.failure do |failed_internship_offer|
            render :new, status: :bad_request
          end
        end
      else
        @organisation = Organisation.find(params[:organisation_id])
        @available_weeks = Week.selectable_from_now_until_end_of_school_year
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
              :weekly_lunch_break,
              weekly_hours: [],
              daily_hours: {},
              daily_lunch_break: {},
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

    def clean_params
      params[:practical_info][:street] = [params[:practical_info][:street], params[:practical_info][:street_complement]].compact_blank.join(' - ')
    end
  end
end
