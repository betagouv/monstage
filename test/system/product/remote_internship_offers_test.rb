
require 'application_system_test_case'

module Product
  class InternshipOfferStepperTest < ApplicationSystemTestCase
    test 'employer_new_dashboard_support_ticket_path' do
      employer = create(:employer)
      school_manager = create(:school_manager, school: create(:school))

      [employer, school_manager].each do |person|
        sign_in(person)

        run_request_and_cache_response(report_as: "#{person}_new_dashboard_support_ticket_path") do
          visit new_dashboard_support_ticket_path(person)
        end
      end
    end
  end
end
