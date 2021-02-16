# frozen_string_literal: true

module ApiTestHelpers
  def documents_as(endpoint:, state:)
    yield
    output_path = Rails.root.join('doc',
                                  'output',
                                  *endpoint.to_s.split('/'),
                                  "#{state}.json")
    File.write(output_path, pretty_json_response)
  end

  def json_response
    JSON.parse(response.body)
  rescue JSON::ParserError
    raise 'Not a json response'
  end

  def json_code
    json_response['code']
  end

  def json_error
    json_response['error']
  end

  def pretty_json_response
    body = JSON.parse(response.body)
    JSON.pretty_generate(body)
  rescue JSON::ParserError
    response.body
  end

  def dictionnary_api_call_stub
    stub_request(:any, /dictionnaire-academie.fr/).to_return(
      status: 200,
      body: '{"result":[{"nature":"n.f.","score":1}]}',
      headers: {}
    )
  end

  def prismic_root_path_stubbing
    mock_prismic = Marshal.load(
      File.read(
        Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump')
      )
    )
    PrismicFinder.stub(:homepage, mock_prismic) { yield }
  end
end
