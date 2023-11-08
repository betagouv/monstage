
require 'test_helper'

module Api
  class AutocompleSireneTest < ActiveSupport::TestCase
    setup do
      @siret = '13002530500010'
      stub_request(:any, /recherche-entreprises.api.gouv.fr/)
      .to_return(status: 200, body: "")

      stub_request(:post, "https://api.insee.fr/token")
        .to_return(status: 200, body: {"access_token": "test"}.to_json, headers: {})

      stub_request(:get, /api.insee.fr/)
        .to_return(status: 200, body: "", headers: {}) 
    end

    test '.search_by_siret' do
      response = AutocompleteSirene.search_by_siret(siret: @siret)
      assert_equal '200', response.code
    end

    test '.search_by_name' do
      response = AutocompleteSirene.search_by_name(name: 'test')
      assert_equal '200', response.code
    end

    test '.search_by_name without params' do
      response = AutocompleteSirene.search_by_name(name: nil)
      assert_nil response
    end
  end
end