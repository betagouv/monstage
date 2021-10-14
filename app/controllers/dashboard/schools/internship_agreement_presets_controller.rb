# frozen_string_literal: true

module Dashboard
  module Schools
    class InternshipAgreementPresetsController < ApplicationController
      include NestedSchool

      def edit
        authorize! :update, @school.internship_agreement_preset
        render :edit
      end

      def update
        authorize! :update, @school.internship_agreement_preset
        @internship_offer_preset = @school.internship_agreement_preset
        @internship_offer_preset.update!(internship_agreement_preset_params)
        redirect_to(dashboard_internship_agreements_path,
                    flash: { success: 'Etablissement mis à jour avec succès' })
      rescue ActiveRecord::RecordInvalid
        render :edit, status: :bad_request
      rescue ActionController::ParameterMissing
        render :edit, status: :unprocessable_entity
      end

      private

      def internship_agreement_preset_params
        params.require(:internship_agreement_preset)
              .permit(:legal_terms_rich_text,
                      :complementary_terms_rich_text,
                      :troisieme_generale_activity_rating_rich_text,
                      :school_delegation_to_sign_delivered_at)
      end
    end
  end
end
