# frozen_string_literal: true

require 'test_helper'

class AirtableSynchronizerTest < ActiveSupport::TestCase
  def setup
    @request_body = File.read(Rails.root.join(*%w[test fixtures files airtable-request.json]))
    @parsed_body = JSON.parse(@request_body)
    stub_request(:get, %r[https://api.airtable.com/*]).
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Bearer keysnrS8qqDtlTl6N',
            'User-Agent'=>'Ruby'
            }).
          to_return(
            status: 200,
            body: @request_body,
            headers: {"Content-Type" => "application/json; charset=utf-8"})

  end

  test '.pull_all truncate table and reload data' do
    AirTableRecord.create!
    assert_changes -> { AirTableRecord.count },
                  from: 1,
                  to: @parsed_body["records"].size do
      AirtableSynchronizer.new.pull_all
    end
  end

  test '.import_record map as expected' do
    airtable_record = Airtable::Record.new(@parsed_body["records"].first)
    assert_changes -> { AirTableRecord.count }, 1 do
      AirtableSynchronizer.new.import_record(airtable_record)
    end
    AirtableSynchronizer::MAPPING.map do |airtable_key, ar_key|
      assert_equal 1, AirTableRecord.where("#{ar_key}" => airtable_record.attributes[airtable_key]).count
    end
  end
end
