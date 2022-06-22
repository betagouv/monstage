class Signature < ApplicationRecord

  enum signatory_role: {
    school_manager: 'school_manager',
    employer: 'employer'
  }

  belongs_to :internship_agreement

  validates :signatory_ip,
            :signature_date,
            :signature_phone_number,
            presence: true
  validates :signatory_role, inclusion: { in: signatory_roles.values }
  validate :no_double_signature?

  delegate :student,        to: :internship_agreement
  delegate :employer,       to: :internship_agreement
  delegate :school_manager, to: :internship_agreement

  def signatures_count
    Signature.where(internship_agreement_id: internship_agreement_id)
             .count
  end

  def self.signatory_roles_count
    Signature.signatory_roles.keys.size
  end

  def all_signed?
    signatures_count == Signature.signatory_roles_count
  end

  def roles_already_signed(internship_agreement_id:)
    Signature.where(internship_agreement_id: internship_agreement_id)
             .pluck(:signatory_role)
  end

  private

  def no_double_signature?
    signed_roles = Signature.where(internship_agreement_id: internship_agreement_id)
                            .pluck(:signatory_role)
    if signed_roles.include?(signatory_role)
      errors.add(:signatory_role, "#{I18n.t signatory_role} a déjà signé")
    end
  end
end
