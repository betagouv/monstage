require 'test_helper'


class ApiAddressProxyControllerTest < ActionDispatch::IntegrationTest
  test 'search forward args to AutocompleteAddress' do
    expected_endpoint = "https://api-adresse.data.gouv.fr/search?limit=10&q=paris"
    expected_response = {
      status: 200,
      body: {hello: :world}.to_json
    }

    stub_request(:get, expected_endpoint).to_return(expected_response)
    get api_address_proxy_search_path({q: :paris})

    assert_response :success
    assert_equal expected_response[:body], response.body
  end
end
