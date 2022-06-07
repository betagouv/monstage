module Dashboard
  module InternshipAgreements
    class SignaturesController < ApplicationController
      def new
      end

      def create
        signature_builder.create(params: internship_signature_params) do |on|
          on.success do |created_internship_signature|
            success_message = 'Votre signature a bien été enregistrée'
            redirect_to(internship_signature_path(created_internship_signature),
                        flash: { success: success_message })
          end
          on.failure do |failed_internship_signature|
            @internship_signature = failed_internship_signature || Signature.new
            render :new, status: :bad_request # TODO BAD
          end
        end
      rescue ActionController::ParameterMissing
        @internship_offer = Signature.new
        render :new, status: :bad_request
      end

      private

      def internship_signature_params
        params.require(:signature)
              .permit(:internship_agreement_id)
      end

      def signature_builder
        @builder ||= Builders::SignatureBuilder.new(user: current_user,
                                                    context: :web)
      end
    end
  end
end
