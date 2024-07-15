require 'test_helper'

module InternshipApplications
  class ButtonComponentTest < ViewComponent::TestCase
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes

    test "when internship_agreement exists, render edit link" do
      employer = create(:employer)
      school = create(:school, :with_school_manager, :with_weeks)
      student = create(:student, :troisieme_generale, school: school)
      internship_offer = create(:weekly_internship_offer, weeks: school.weeks)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      internship_offer: internship_offer,
                                      user_id: student.id)
      internship_agreement = create(:internship_agreement, :created_by_system,
                                    internship_application: internship_application)
      render_inline(InternshipApplications::ButtonComponent.new(internship_application: internship_agreement.internship_application,
                                        current_user: employer))

      assert_selector("a[href=\"#{url_helpers.edit_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)}\"]")
    end

    test "when internship_agreement render progress when i signed" do
      employer = create(:employer)
      school = create(:school, :with_school_manager, :with_weeks)
      student = create(:student, :troisieme_generale, school: school)
      internship_offer = create(:weekly_internship_offer, weeks: school.weeks)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      internship_offer: internship_offer,
                                      user_id: student.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application,
                                                           employer_accept_terms: true,
                                                           school_manager_accept_terms: false)
      render_inline(InternshipApplications::ButtonComponent.new(
        internship_application: internship_agreement.internship_application,
        current_user: employer
      ))

      assert_selector("[data-test=\"inactive-internship-agreement-progress-#{internship_agreement.id}\"]")
    end

    test "when internship_agreement render print link when eveeryone has signed" do
      employer = create(:employer)
      school = create(:school, :with_school_manager, :with_weeks)
      student = create(:student, :troisieme_generale, school: school)
      internship_offer = create(:weekly_internship_offer, weeks: school.weeks)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      internship_offer: internship_offer,
                                      user_id: student.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application,
                                                           employer_accept_terms: true,
                                                           school_manager_accept_terms: true)
      render_inline(InternshipApplications::ButtonComponent.new(
        internship_application: internship_agreement.internship_application,
        current_user: employer
      ))

      assert_selector("a[href=\"#{url_helpers.dashboard_internship_agreement_path(uuid: internship_agreement.uuid,format: :pdf)}\"]")
    end
  end
end
