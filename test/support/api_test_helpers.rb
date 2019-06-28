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
    fail "Not a json response"
  end

  def pretty_json_response
    body = JSON.parse(response.body)
    JSON.pretty_generate(body)
  rescue JSON::ParserError
    response.body
  end
end
