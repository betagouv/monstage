# frozen_string_literal: true

module ApiTestHelpers
  def documents_as(endpoint:, state:)
    yield
    File.write(Rails.root.join('doc', *endpoint.to_s.split('/'), "#{state}.json"), response.body)
  end

  def json_response
    JSON.parse(response.body)
  end
end
