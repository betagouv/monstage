class SidemenuComponentPreview < ViewComponent::Preview
  layout "preview"
  def _offers_active_without_agreements_authorization
    internship_agreement = InternshipAgreement.first

    cmpnt = SidemenuComponent.new(candidatures_notice: 1,
                                  agreements_notice: 2,
                                  agreements_authorization: false,
                                  current_page_offers: true,
                                  current_page_candidatures: false,
                                  current_page_agreements: false)
    render cmpnt
  end

  def _offers_active_with_agreements_authorization
    internship_agreement = InternshipAgreement.first

    cmpnt = SidemenuComponent.new(candidatures_notice: 1,
                                  agreements_notice: 2,
                                  agreements_authorization: true,
                                  current_page_offers: true,
                                  current_page_candidatures: false,
                                  current_page_agreements: false)
    render cmpnt
  end

  def _applications_active_with_agreements_authorization
    internship_agreement = InternshipAgreement.first

    cmpnt = SidemenuComponent.new(candidatures_notice: 1,
                                  agreements_notice: 2,
                                  agreements_authorization: true,
                                  current_page_offers: false,
                                  current_page_candidatures: true,
                                  current_page_agreements: false)
    render cmpnt
  end

  def _agreements_active_with_agreements_authorization
    internship_agreement = InternshipAgreement.first

    cmpnt = SidemenuComponent.new(candidatures_notice: 1,
                                  agreements_notice: 2,
                                  agreements_authorization: true,
                                  current_page_offers: false,
                                  current_page_candidatures: false,
                                  current_page_agreements: true)
    render cmpnt
  end
end