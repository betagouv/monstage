# frozen_string_literal: true

require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'create enqueue SyncInternshipOfferKeywordsJob' do
    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      create(:weekly_internship_offer)
    end
  end

  test 'destroy enqueue SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.destroy
    end
  end

  test 'update title enqueues SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(title: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(description_rich_text: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(employer_description_rich_text: 'bingo bango bang')
    end

    assert_enqueued_jobs 0, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(first_date: 2.days.from_now)
    end
  end
end
