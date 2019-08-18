# frozen_string_literal: true

module Dashboard
  class SchoolsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_school, only: %i[edit update show]
    before_action :find_selectable_weeks, only: %i[edit update]

    def index
      authorize! :index, School
      @schools = School.all.order(zipcode: :desc)
    end

    def edit
      authorize! :edit, School
    end

    def update
      authorize! :update, School
      @school.update!(internship_weeks_params)
      if current_user.is_a?(Users::God)
        redirect_to(dashboard_schools_path(anchor: "school_#{@school.id}"),
                    flash: { success: 'Collège mis à jour avec succès' })
      else
        redirect_to(dashboard_school_class_rooms_path(@school),
                    flash: { success: 'Collège mis à jour avec succès' })
      end
    rescue ActiveRecord::RecordInvalid
      render :edit, status: :bad_request
    end

    private

    def set_school
      @school = School.find(params.require(:id))
    end

    def internship_weeks_params
      current_user.is_a?(Users::God) ?
        god_internship_weeks_params :
        school_manager_internship_weeks_params
    end

    def god_internship_weeks_params
        params.require(:school).permit(:zipcode,
                                     :city,
                                     :street,
                                     :name,
                                     :visible,
                                     coordinates: {},
                                     week_ids: [])
    end

    def school_manager_internship_weeks_params
        params.require(:school).permit(week_ids: [])
    end
  end
end
