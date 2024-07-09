# frozen_string_literal: true

require 'test_helper'

class InternshipOfferPaginationTest < ActiveSupport::TestCase
  setup do
    @internship_offer_1 = create(:weekly_internship_offer, total_applications_count: 1)
    @internship_offer_1.stats.update_attribute(:total_applications_count, 1)
    @internship_offer_2 = create(:weekly_internship_offer, total_applications_count: 2)
    @internship_offer_2.stats.update_attribute(:total_applications_count, 2)
    @internship_offer_3 = create(:weekly_internship_offer, total_applications_count: 3)
    @internship_offer_3.stats.update_attribute(:total_applications_count, 3)
    @internship_offer_4 = create(:weekly_internship_offer, total_applications_count: 4)
    @internship_offer_4.stats.update_attribute(:total_applications_count, 4)
    @internship_offer_5 = create(:weekly_internship_offer, total_applications_count: 5)
    @internship_offer_5.stats.update_attribute(:total_applications_count, 5)
  end

  test '.next_from (asc)' do
    from = InternshipOffer.all.order(total_applications_count: :asc)
    assert_equal [1, 2, 3, 4, 5], from.map(&:total_applications_count)
    next_item = from.next_from(current: @internship_offer_1,
                               column: :total_applications_count,
                               order: :asc)
                    .limit(1)
    assert_equal @internship_offer_2, next_item.first

    next_item = from.next_from(current: @internship_offer_2,
                               column: :total_applications_count,
                               order: :asc)
                    .limit(1)
    assert_equal @internship_offer_3, next_item.first

    next_item = from.next_from(current: @internship_offer_3,
                               column: :total_applications_count,
                               order: :asc)
                    .limit(1)
    assert_equal @internship_offer_4, next_item.first

    next_item = from.next_from(current: @internship_offer_4,
                               column: :total_applications_count,
                               order: :asc)
                    .limit(1)
    assert_equal @internship_offer_5, next_item.first

    next_item = from.next_from(current: @internship_offer_5,
                               column: :total_applications_count,
                               order: :asc)
                    .limit(1)
    assert_nil next_item.first
  end

  test '.next_from (desc)' do
    from = InternshipOffer.all.order(total_applications_count: :desc)
    assert_equal [5, 4, 3, 2, 1], from.map(&:total_applications_count)
    next_item = from.next_from(current: @internship_offer_1,
                               column: :total_applications_count,
                               order: :desc)
                    .limit(1)
    assert_nil nil, next_item.first

    next_item = from.next_from(current: @internship_offer_2,
                               column: :total_applications_count,
                               order: :desc)
                    .limit(1)
    assert_equal @internship_offer_1, next_item.first

    next_item = from.next_from(current: @internship_offer_3,
                               column: :total_applications_count,
                               order: :desc)
                    .limit(1)
    assert_equal @internship_offer_2, next_item.first

    next_item = from.next_from(current: @internship_offer_4,
                               column: :total_applications_count,
                               order: :desc)
                    .limit(1)
    assert_equal @internship_offer_3, next_item.first

    next_item = from.next_from(current: @internship_offer_5,
                               column: :total_applications_count,
                               order: :desc)
                    .limit(1)
    assert_equal @internship_offer_4, next_item.first
  end

  test '.previous_from (asc)' do
    from = InternshipOffer.all.order(total_applications_count: :asc)

    assert_equal [1, 2, 3, 4, 5], from.map(&:total_applications_count)
    previous_item = from.previous_from(current: @internship_offer_1,
                                       column: :total_applications_count,
                                       order: :asc)
                        .limit(1)
    assert_nil previous_item.first

    previous_item = from.previous_from(current: @internship_offer_2,
                                       column: :total_applications_count,
                                       order: :asc)
                        .limit(1)
    assert_equal @internship_offer_1, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_3,
                                       column: :total_applications_count,
                                       order: :asc)
                        .limit(1)
    assert_equal @internship_offer_2, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_4,
                                       column: :total_applications_count,
                                       order: :asc)
                        .limit(1)
    assert_equal @internship_offer_3, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_5,
                                       column: :total_applications_count,
                                       order: :asc)
                        .limit(1)
    assert_equal @internship_offer_4, previous_item.first
  end

  test '.previous_from (desc)' do
    from = InternshipOffer.all.order(total_applications_count: :desc)
    assert_equal [5, 4, 3, 2, 1], from.map(&:total_applications_count)
    $debug = true
    previous_item = from.previous_from(current: @internship_offer_1,
                                       column: :total_applications_count,
                                       order: :desc)
                        .limit(1)
    assert_equal @internship_offer_2, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_2,
                                       column: :total_applications_count,
                                       order: :desc)
                        .limit(1)
    assert_equal @internship_offer_3, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_3,
                                       column: :total_applications_count,
                                       order: :desc)
                        .limit(1)
    assert_equal @internship_offer_4, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_4,
                                       column: :total_applications_count,
                                       order: :desc)
                        .limit(1)
    assert_equal @internship_offer_5, previous_item.first

    previous_item = from.previous_from(current: @internship_offer_5,
                                       column: :total_applications_count,
                                       order: :desc)
                        .limit(1)
    assert_nil previous_item.first
  end
end
