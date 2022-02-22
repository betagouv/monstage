class ProgressComponentPreview < ViewComponent::Preview
  layout "preview"

  def _1_with_pending_signatures
    employer = Users::Employer.first
    internship_application = employer.internship_applications
                                     .joins(:internship_agreement)
                                     .first

    render(InternshipAgreements::ProgressComponent.new(
      internship_agreement: internship_application.internship_agreement,
      current_user: employer
    ))
  end

  def _2_with_all_signatures
    internship_agreement = InternshipAgreement.where(school_manager_accept_terms: true,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ProgressComponent.new(
      internship_agreement: internship_agreement,
      current_user: internship_agreement.internship_application.internship_offer.employer
    ))
  end
end

