class Tutor < ApplicationRecord
  # Validations
  validates :tutor_name, :tutor_phone, :tutor_email, presence: true
  belongs_to :employer, class_name: 'User'

  def anonymize
    fields_to_reset = {
      tutor_name: 'NA',
      tutor_phone: 'NA',
      tutor_email: 'NA'
    }
    update(fields_to_reset)
    discard
  end
end
