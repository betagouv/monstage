# frozen_string_literal: true

require 'test_helper'

class InternshipOfferWeekTest < ActiveSupport::TestCase
  test 'works' do
    iow = build(:internship_offer_week)
    assert iow.valid?
  end
end
