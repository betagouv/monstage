# frozen_string_literal: true

module Reporting
  class OperatorsController < BaseReportingController

    def index
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)
      
      @operators = Operator.all.order(:name)
      respond_to do |format|
        format.xlsx do
          @school_year = params[:school_year] || SchoolYear::Current.new.beginning_of_period.year
          response.headers['Content-Disposition'] = %(attachment; filename="#{export_filename('assocations')}.xlsx")
        end
        format.html do
          params[:school_year] ||= SchoolYear::Current.new.beginning_of_period.year
        end
      end
    end

    def update
      authorize! :update, Operator
      operator = Operator.find(params[:operator][:id])
      params[:operator][:realized_count] = operator.realized_count.merge(realized_count_hash)
      if operator
        operator.update(operator_params)
        redirect_to reporting_operators_path, flash: { success: "#{operator.name} mise à jour." }
      else
        redirect_to reporting_operators_path, flash: { error: "Impossible de mettre à jour l'association." }
      end
    end

    private

    def operator_params
      params.require(:operator).permit(:id, :target_count, realized_count: {})
    end

    def realized_count_hash
      { params[:operator][:school_year] => { 
          total: calulate_total_count,
          onsite: params[:operator][:onsite_count].to_i,
          hybrid: params[:operator][:hybrid_count].to_i,
          online: params[:operator][:online_count].to_i,
          workshop: params[:operator][:workshop_count].to_i,
          public: params[:operator][:public_count].to_i,
          private: params[:operator][:private_count].to_i,
        }
      }
    end

    def calulate_total_count
      onsite = params[:operator][:onsite_count].to_i
      hybrid = params[:operator][:hybrid_count].to_i
      online = params[:operator][:online_count].to_i
      onsite + hybrid + online
    end
  end
end
