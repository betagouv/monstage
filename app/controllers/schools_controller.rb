# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize! :new, School
    @school = School.new
  end

  def create
    authorize! :new, School
    @school = School.new(school_params)
    if @school.save
      redirect_to rails_admin_path, flash: { success: 'Etablissement créé !' }
    else
      flash[:error] = 'Erreur lors de la validation des informations'
      render :new
    end
  end

  private

  def school_params
    params.require(:school)
          .permit(
            :zipcode,
            :code_uai,
            :city,
            :street,
            :name,
            :kind,
            :visible,
            coordinates: {},
            week_ids: [])
  end
end
