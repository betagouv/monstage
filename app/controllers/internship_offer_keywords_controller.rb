# frozen_string_literal: true

class InternshipOfferKeywordsController < ApplicationController
  protect_from_forgery with: :null_session
  def search
    render json: InternshipOfferKeyword.search(params.require(:keyword))
                                       .limit(10),
           status: 200
  end
end
