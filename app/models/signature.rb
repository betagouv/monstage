class Signature < ApplicationRecord

  enum signatory_role: {
    school_manager: 'school_manager',
    employer: 'employer'
  }

  belongs_to :internship_agreement

  validates :signatory_ip,
            :signature_date,
            presence: true
  validates :signatory_role, inclusion: { in: signatory_roles.values }
  validate :no_double_signature?

  delegate :student,        to: :internship_agreement
  delegate :employer,       to: :internship_agreement
  delegate :school_manager, to: :internship_agreement

  scope :signatures, ->(internship_agreement_id:){
    where(internship_agreement_id: internship_agreement_id)
  }

  def signatures_count
    Signature.signatures(internship_agreement_id: internship_agreement_id)
             .count
  end

  def self.signatory_roles_count
    Signature.signatory_roles.keys.size
  end

  def signatory_roles_count
    Signature.signatory_roles.keys.size
  end

  def all_signed?
    signatures_count == signatory_roles_count
  end

  def only_started_to_sign?
    (1...signatory_roles_count).include?(signatures_count)
  end

  def self.roles_already_signed(internship_agreement_id:)
    Signature.signatures(internship_agreement_id: internship_agreement_id)
             .pluck(:signatory_role)
  end

  def self.already_signed?(user_role:, internship_agreement_id: )
    roles_signed = roles_already_signed(internship_agreement_id: internship_agreement_id)
    roles_signed.include?(user_role.to_s)
  end

  def self.missing_signatures(internship_agreement_id: )
    self.signatory_roles.keys - self.roles_already_signed(internship_agreement_id: internship_agreement_id)
  end


  private


  def no_double_signature?
    signed_roles = Signature.signatures(internship_agreement_id: internship_agreement_id)
                            .pluck(:signatory_role)
    if signed_roles.include?(signatory_role)
      errors.add(:signatory_role, "#{I18n.t signatory_role} a déjà signé")
    end
  end
end
