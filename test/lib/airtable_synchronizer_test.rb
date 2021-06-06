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

  test '.pull_all fails gracefully (does not destroy existing data when there is a failure) if needed' do
    AirTableRecord.create!
    airtable_record = Airtable::Record.new(@parsed_body["records"].first["fields"])
    sync = AirtableSynchronizer.new
    raises_exception = proc { |_| raise ArgumentError.new }
    assert_no_changes -> { AirTableRecord.count } do
      AirTableRecord.stub :create!, raises_exception do
        assert_raise { sync.pull_all }
      end
    end
  end

  test '.import_record map as expected' do
    airtable_record = Airtable::Record.new(@parsed_body["records"].first["fields"])
    assert_changes -> { AirTableRecord.count }, 1 do
      AirtableSynchronizer.new.import_record(airtable_record)
    end
    AirtableSynchronizer::MAPPING.map do |airtable_key, ar_key|
      assert_equal 1, AirTableRecord.where("#{ar_key}" => airtable_record.attributes[airtable_key]).count
    end
  end

  test '.import_record ignore empty records' do
    request_body_with_empty_records = File.read(Rails.root.join(*%w[test fixtures files airtable-request-empty-records.json]))
    request_body_with_empty_records = JSON.parse(request_body_with_empty_records)

    airtable_record = Airtable::Record.new(request_body_with_empty_records["records"][2]["fields"])
    assert_no_changes -> { AirTableRecord.count }, 1 do
      AirtableSynchronizer.new.import_record(airtable_record)
    end
  end

  test 'cast_internship_offer_type(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = "same"
    assert_equal value, airtable_sync.cast_internship_offer_type(value)
  end

  test 'cast_is_public(value)' do
    airtable_sync = AirtableSynchronizer.new
    refute airtable_sync.cast_is_public ("Privé")
    assert airtable_sync.cast_is_public ("Public")
  end

  test 'cast_nb_spot_female(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = 1
    assert_equal value, airtable_sync.cast_nb_spot_female(value)
  end

  test 'cast_school_track(value)' do
    airtable_sync = AirtableSynchronizer.new
    assert_equal :troisieme_generale, airtable_sync.cast_school_track("3e")
  end

  test 'cast_nb_spot_available(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = 1
    assert_equal value, airtable_sync.cast_nb_spot_available(value)
  end

  test 'cast_school_name(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = "str"
    assert_equal value, airtable_sync.cast_school_name(value)
  end

  test 'cast_nb_spot_used(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = 1
    assert_equal value, airtable_sync.cast_nb_spot_used(value)
  end

  test 'cast_nb_spot_male(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = 1
    assert_equal value, airtable_sync.cast_nb_spot_male(value)
  end

  test 'cast_organisation_name(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = "str"
    assert_equal value, airtable_sync.cast_organisation_name(value)
  end

  test 'cast_sector_name(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = "str"
    assert_equal value, airtable_sync.cast_sector_name(value)
  end

  test 'cast_department_name(value)' do
    airtable_sync = AirtableSynchronizer.new
    value = "str"
    assert_equal value, airtable_sync.cast_department_name(value)
  end
end
