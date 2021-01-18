require 'test_helper'

module InternshipAgreements
  class ButtonComponentTest < ViewComponent::TestCase
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes

    test "when internship_agreement does not exists, render create link" do
      employer = create(:employer)
      internship_application = create(:weekly_internship_application)
      render_inline(InternshipAgreements::ButtonComponent.new(internship_application: internship_application,
                                        current_user: employer))

      assert_selector("a[href=\"#{url_helpers.new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)}\"]")
    end

    test "when internship_agreement exists, render edit link" do
      employer = create(:employer)
      internship_agreement = create(:internship_agreement)
      render_inline(InternshipAgreements::ButtonComponent.new(internship_application: internship_agreement.internship_application,
                                        current_user: employer))

      assert_selector("a[href=\"#{url_helpers.edit_dashboard_internship_agreement_path(internship_agreement)}\"]")
    end

    test "when internship_agreement render progress when i signed" do
      employer = create(:employer)
      internship_agreement = create(:internship_agreement, employer_accept_terms: true,
                                                           school_manager_accept_terms: false)
      render_inline(InternshipAgreements::ButtonComponent.new(internship_application: internship_agreement.internship_application,
                                        current_user: employer))

      assert_selector("[data-test=\"internship-agreement-progress-#{internship_agreement.id}\"]")
    end

    test "when internship_agreement render print link when eveeryone has signed" do
      employer = create(:employer)
      internship_agreement = create(:internship_agreement, employer_accept_terms: true,
                                                           school_manager_accept_terms: true)
      render_inline(InternshipAgreements::ButtonComponent.new(internship_application: internship_agreement.internship_application,
                                        current_user: employer))

      assert_selector("a[href=\"#{url_helpers.dashboard_internship_agreement_path(internship_agreement,format: :pdf)}\"]")
    end
  end
end
