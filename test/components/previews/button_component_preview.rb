class ButtonComponentPreview < ViewComponent::Preview
  layout "preview"

  def _1_not_signed
    employer = Users::Employer.first

    render(InternshipAgreements::ButtonComponent.new(
      internship_application: employer.internship_applications
                                      .approved
                                      .joins(:internship_agreement)
                                      .first,
      current_user: employer)
    )
  end

  def _2_signed_by_me
    internship_agreement = InternshipAgreement.where(school_manager_accept_terms: false,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ButtonComponent.new(
      internship_application: internship_agreement.internship_application,
      current_user: internship_agreement.internship_application.internship_offer.employer
    ))
  end

  def _3_signed_by_everyone
    internship_agreement = InternshipAgreement.where(school_manager_accept_terms: true,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ButtonComponent.new(
      internship_application: internship_agreement.internship_application,
      current_user: internship_agreement.internship_application.internship_offer.employer
    ))
  end
end

