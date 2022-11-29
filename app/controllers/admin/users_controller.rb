module Admin
  class UsersController < ApplicationController
    def new
      response = Api::AutocompleteSirene.search_by_siret(siret: params[:siret])
      render json: response.body, status: response.code
    end

    def migrate_employer_to_referent
      authorize! :user_migrations, current_user
      # current_user.update!(role: :referent)
      render ''
      redirect_to account_path(section: :password),
                  flash: { success: 'Votre compte est au top' }
    end
  end
end