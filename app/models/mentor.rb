class Mentor < ApplicationRecord
  # Validations
  validates :name, :phone, :email, presence: true

  def anonymize
    fields_to_reset = {
      name: 'NA',
      phone: 'NA',
      email: 'NA'
    }
    update(fields_to_reset)
    discard
  end
end
