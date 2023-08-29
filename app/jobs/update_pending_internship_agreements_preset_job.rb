class UpdatePendingInternshipAgreementsPresetJob < ActiveJob::Base
  queue_as :default

  def perform(school:)
    @school = school
    update_pending_internship_agreements
  end

  private

  def update_pending_internship_agreements
    pending_internship_agreements.find_each do |agreement|
      agreement.update(
        school_delegation_to_sign_delivered_at: @school.internship_agreement_preset.school_delegation_to_sign_delivered_at,
        legal_terms_rich_text: @school.internship_agreement_preset.legal_terms_rich_text.body,
        complementary_terms_rich_text: @school.internship_agreement_preset.complementary_terms_rich_text.body,
        activity_rating_rich_text: @school.internship_agreement_preset.troisieme_generale_activity_rating_rich_text.body,
      )
    end
  end

  def pending_internship_agreements
    @school.internship_agreements
           .kept
           .where.not(aasm_state: :validated)
  end
end