# frozen_string_literal: true

module Reporting
  class OperatorsController < BaseReportingController

    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      @operators = Operator.all.order(:name)
      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('assocations')}.xlsx")
        end
        format.html do
        end
      end
    end

    def update
      authorize! :update, Operator
      operator = Operator.find(params[:operator][:id])
      if operator
        operator.update(operator_params)
        redirect_to reporting_operators_path, flash: { success: 'Association mise à jour.' }
      else
        redirect_to reporting_operators_path, flash: { error: "Impossible de mettre à jour l'association." }
      end
    end

    private

    def operator_params
      params.require(:operator).permit(:id, :target_count)
    end
  end
end
