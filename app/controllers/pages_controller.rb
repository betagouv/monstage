# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @prismic = PrismicClient.query(Prismic::Predicates.at("document.type", "homepage")).results[0]
  end
end
