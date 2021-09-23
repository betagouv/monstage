# frozen_string_literal: true

module Api
  class InternshipOffersController < ApiBaseController
    before_action :authenticate_api_user!

    def create
      internship_offer_builder.create(params: create_internship_offer_params) do |on|
        on.success(&method(:render_created))
        on.failure(&method(:render_validation_error))
        on.duplicate(&method(:render_duplicate))
        on.argument_error(&method(:render_argument_error))
      end
    end

    def update
      internship_offer_builder.update(instance: InternshipOffer.find_by!(remote_id: params[:id]),
                                      params: update_internship_offer_params) do |on|
        on.success(&method(:render_ok))
        on.failure(&method(:render_validation_error))
        on.argument_error(&method(:render_argument_error))
      end
    end

    def destroy
      internship_offer_builder.discard(instance: InternshipOffer.find_by!(remote_id: params[:id])) do |on|
        on.success(&method(:render_no_content))
        on.failure(&method(:render_discard_error))
      end
    end

    private

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_api_user,
                                                        context: :api)
    end

    def create_internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title,
              :description,
              :employer_name,
              :employer_description,
              :employer_website,
              :street,
              :zipcode,
              :city,
              :remote_id,
              :permalink,
              :sector_uuid,
              :type,
              :max_candidates,
              :max_student_group_size,
              coordinates: {},
              weeks: []
            )
    end

    def update_internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title,
              :description,
              :employer_name,
              :employer_description,
              :employer_website,
              :street,
              :zipcode,
              :city,
              :permalink,
              :sector_uuid,
              :max_candidates,
              :max_student_group_size,
              :published_at,
              coordinates: {},
              weeks: []
            )
    end
  end
end
