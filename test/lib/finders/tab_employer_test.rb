# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabEmployerTest < ActiveSupport::TestCase
    test 'pending_agreements_count do not only count 3e generale applications' do
      employer = create(:employer)
      internship_offer = create(:free_date_internship_offer,employer: employer)

      draft_internship_application = create(:free_date_internship_application,
                                            :drafted,
                                            internship_offer: internship_offer)
      approved_internship_application = create(:free_date_internship_application,
                                               :approved,
                                               internship_offer: internship_offer)
      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end

    test 'pending_agreements_count include approved and exclude draft applications' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer,employer: employer)

      draft_internship_application = create(:weekly_internship_application,
                                            :drafted,
                                            internship_offer: internship_offer)
      approved_internship_application = create(:weekly_internship_application,
                                               :approved,
                                               internship_offer: internship_offer)
      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end

    test 'pending_agreements_count include created agreements but not signed by employer' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer,employer: employer)

      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      internship_offer: internship_offer)
      create(:internship_agreement, internship_application: internship_application,
                                    employer_accept_terms: false,
                                    school_manager_accept_terms: true)
      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end

    test 'pending_agreements_count ignored created agreements but not signed by other employer' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer,employer: employer)

      internship_application = create(:weekly_internship_application,
                                      :approved)
      create(:internship_agreement, internship_application: internship_application,
                                    employer_accept_terms: false,
                                    school_manager_accept_terms: true)
      employer_tab = TabEmployer.new(user: employer)
      assert_equal 0, employer_tab.pending_agreements_count
    end

    test 'pending_agreements_count ignored created agreements signed by himself' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer,employer: employer)

      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      internship_offer: internship_offer)
      create(:internship_agreement, internship_application: internship_application,
                                    employer_accept_terms: true)
      employer_tab = TabEmployer.new(user: employer)
      assert_equal 0, employer_tab.pending_agreements_count
    end


  end
end
