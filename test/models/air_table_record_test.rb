# frozen_string_literal: true

require 'test_helper'

class AirTableRecordTest < ActiveSupport::TestCase
  test 'by_type' do
    create(:air_table_record, nb_spot_used: 10, internship_offer_type: 'A')
    create(:air_table_record, nb_spot_used: 10, internship_offer_type: 'A')
    create(:air_table_record, nb_spot_used: 10, internship_offer_type: 'B')

    result = AirTableRecord.by_type

    assert_includes(result.map(&:attributes), {"total"=>10, "internship_offer_type"=>"B", "id"=>nil})
    assert_includes(result.map(&:attributes), {"total"=>20, "internship_offer_type"=>"A", "id"=>nil})
  end
end
