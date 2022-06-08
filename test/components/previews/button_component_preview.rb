class ButtonComponentPreview < ViewComponent::Preview
  layout "preview"

  def _1_with_no_validation
    internship_agreement = InternshipAgreement.draft.first

    render(InternshipAgreements::ButtonComponent.new(
      internship_agreement: internship_agreement,
      current_user: internship_agreement.employer)
    )
  end

  def _2_with_employer_validation
    internship_agreement = InternshipAgreement.completed_by_employer
                                              .where(school_manager_accept_terms: false,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ButtonComponent.new(
      internship_agreement: internship_agreement,
      current_user: internship_agreement.employer
    ))
  end

  def _3_with_every_validation
    internship_agreement = InternshipAgreement.where(school_manager_accept_terms: true,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ButtonComponent.new(
      internship_agreement: internship_agreement,
      current_user: internship_agreement.employer
    ))
  end

  def _4_with_signature_started
    internship_agreement = InternshipAgreement.signatures_started
                                              .where(school_manager_accept_terms: true,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ButtonComponent.new(
      internship_agreement: internship_agreement,
      current_user: internship_agreement.employer
    ))
  end

  def _5_with_signature_process_finished
    internship_agreement = InternshipAgreement.signed_by_all
                                              .where(school_manager_accept_terms: true,
                                                     employer_accept_terms: true)
                                              .first

    render(InternshipAgreements::ButtonComponent.new(
      internship_agreement: internship_agreement,
      current_user: internship_agreement.employer
    ))
  end
end

