# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiAddressProxyController < ApplicationController
  def search
    render json: Api::AutocompleteAddress.search(params: params.permit(:q, :limit))
  end
end

