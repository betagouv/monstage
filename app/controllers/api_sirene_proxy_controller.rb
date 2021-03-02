# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiSireneProxyController < ApplicationController
  def search
     render json: Api::AutocompleteSirene.search_by_siren(params: params.permit(:siren)).body
  end
end

