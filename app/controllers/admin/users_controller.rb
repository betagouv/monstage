module Admin
  class UsersController < ApplicationController
    def new
      response = Api::AutocompleteSirene.search_by_siret(siret: params[:siret])
      render json: response.body, status: response.code
    end
  end
end