module Dashboard
  class SchoolsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_school, only: [:edit, :update]
    before_action :find_selectable_weeks, only: [:edit, :update]

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
      redirect_to(account_path,
                  flash: {success: "Collège mis à jour avec succès"})
    rescue ActiveRecord::RecordInvalid => error
      render :edit, status: :bad_request
    end

    private

    def set_school
      @school = School.find(params.require(:id))
    end

    def internship_weeks_params
      params.require(:school).permit(:zipcode, :city, :street, coordinates: {}, week_ids: [])
    end
  end
end
