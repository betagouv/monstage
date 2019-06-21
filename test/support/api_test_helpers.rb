# frozen_string_literal: true

module ApiTestHelpers
  def write_response_as(report_as:)
    yield
    File.write(Rails.root.join('doc', "#{report_as}.json"), response.body)
  end

  def json_response
    JSON.parse(response.body)
  end
end
