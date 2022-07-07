class Signature < ApplicationRecord
  has_one_attached :signature_image

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

  def presenter
    Presenters::Signature.new(signature: self)
  end

  def signature_file_name
    "signature-#{Rails.env}-#{signatory_role}-#{internship_agreement_id}.png"
  end

  def local_signature_image_file_path
    "storage/signatures/#{signature_file_name}"
  end

  def clean_local_signature_file
    if signature_image.attached? && File.exists?(self.local_signature_image_file_path)
      File.delete(self.local_signature_image_file_path)
    end
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
