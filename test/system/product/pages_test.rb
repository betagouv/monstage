# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class HomeValidationTest < ApplicationSystemTestCase

    include Html5Validator
    include Devise::Test::IntegrationHelpers


    test 'USE_W3C, static pages' do
      %i[
        root_path
        les_10_commandements_d_une_bonne_offre_path
        exemple_offre_ideale_ministere_path
        exemple_offre_ideale_sport_path
        mentions_legales_path
        conditions_d_utilisation_path
        politique_de_confidentialite_path
        contact_path
        accessibilite_path
        documents_utiles_path
        operators_path
        statistiques_path
      ].map do |page_path|
        run_request_and_cache_response(report_as: page_path.to_s) do
          path = Rails.application.routes.url_helpers.send(page_path)
          visit path
        end
      end
    end
  end
end
