# frozen_string_literal: true

module Reporting
  class PartnersController < BaseReportingController

    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      @partners = Partner.all.order(:name)
      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('assocations')}.xlsx")
        end
        format.html do
        end
      end
    end

    def update
      authorize! :update, Partner
      partner = Partner.find(params[:partner][:id])
      if partner
        partner.update(partner_params)
        redirect_to reporting_partners_path, flash: { success: 'Association mise à jour.' }
      else
        redirect_to reporting_partners_path, flash: { error: "Impossible de mettre à jour l'association."}
      end
    end

    private

    def partner_params
      params.require(:partner).permit(:id, :target_count)
    end
  end
end
