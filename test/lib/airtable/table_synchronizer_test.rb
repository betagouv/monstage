# frozen_string_literal: true

require 'test_helper'
module Airtable
  class SynchronizerTest < ActiveSupport::TestCase
    def setup
      ref_school_year = SchoolYear::Floating.new_by_year(year: ENV['AIRTABLE_OPEN_YEAR'].split('-').first.to_i)
      @ref_week = Week.selectable_on_specific_school_year(school_year: ref_school_year).first
      template= File.read(Rails.root.join(*%w[test fixtures files airtable-request.json.erb]))
      @request_body = ERB.new(template)
                         .result(OpenStruct.new(week: @ref_week).instance_eval { binding })
      @parsed_body = JSON.parse(@request_body)
      @operator = create(:operator, name: 'unstageetapres')
      stub_request(:get, %r[https://api.airtable.com/*]).
            with(
              headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=> %r[Bearer*],
              'User-Agent'=>'Ruby'
              }).
            to_return(
              status: 200,
              body: @request_body,
              headers: {"Content-Type" => "application/json; charset=utf-8"})

    end

    test '.pull_all delete past record for current operator and reload data' do
      travel_to Time.new(ENV['AIRTABLE_OPEN_YEAR'].split('-').first.to_i, 9, 1) do
        AirTableRecord.create!(operator: @operator, week: @ref_week)
        assert_changes -> { AirTableRecord.count },
                      from: 1,
                      to: @parsed_body["records"].size do   

          Airtable::TableSynchronizer.new(operator: @operator)
                         .pull_all
        end
      end
    end

    test '.pull_all fails gracefully (does not destroy existing data when there is a failure) if needed' do
      AirTableRecord.create!(operator: @operator, week: @ref_week)
      airtable_record = Airtable::Record.new(@parsed_body["records"].first["fields"])
      sync = Airtable::TableSynchronizer.new(operator: @operator)

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
        Airtable::TableSynchronizer.new(operator: @operator)
                                   .import_record(airtable_record)
      end

      {"nombre_d'élèves_féminins"=> :nb_spot_female,
      "nombre_de_places_disponibles"=> :nb_spot_available,
      "nombre_d'élèves_en_stage"=> :nb_spot_used,
      "nombre_d'élèves_masculins"=> :nb_spot_male}.map do |airtable_key, ar_key|
        assert_equal 1, AirTableRecord.where("#{ar_key}" => airtable_record.attributes[airtable_key]).count
      end
    end

    test '.import_record ignore empty records' do
      request_body_with_empty_records = File.read(Rails.root.join(*%w[test fixtures files airtable-request-empty-records.json]))
      request_body_with_empty_records = JSON.parse(request_body_with_empty_records)

      airtable_record = Airtable::Record.new(request_body_with_empty_records["records"][2]["fields"])
      assert_no_changes -> { AirTableRecord.count }, 1 do
        Airtable::TableSynchronizer.new(operator: @operator).import_record(airtable_record)
      end
    end

    test 'cast_is_public(value)' do
      airtable_sync = Airtable::TableSynchronizer.new(operator: @operator)

      refute airtable_sync.cast_is_public("Privé")
      assert airtable_sync.cast_is_public("Public")
    end

    test 'cast_operator_id(value)' do
      @operator.save!
      @operator.reload
      airtable_sync = Airtable::TableSynchronizer.new(operator: @operator)

      assert_equal @operator.id, airtable_sync.cast_operator_id(@operator.id)
    end

    test 'cast_school_track(value)' do
      airtable_sync = Airtable::TableSynchronizer.new(operator: @operator)

      assert_equal :troisieme_generale, airtable_sync.cast_school_track("3e")
    end

    test 'cast_department_name(value)' do
      airtable_sync = Airtable::TableSynchronizer.new(operator: @operator)

      value = ["60"]
      assert_equal "Oise", airtable_sync.cast_department_name(value)
    end

  end
end
