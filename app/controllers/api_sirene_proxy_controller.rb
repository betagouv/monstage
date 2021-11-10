# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiSireneProxyController < ApplicationController
  def search
    response = Api::AutocompleteSirene.search_by_siret(siret: params[:siret])
    render json: response.body, status: response.code
  end
end

