class SupportTicket
  include ActiveModel::Model

  attr_accessor :user_id,
                :message,
                :webinar,
                :face_to_face,
                :subject,
                :school_id

  validates :message, :user_id, presence: true
  validate :one_mode_minimum

  private

  def one_mode_minimum
    if (webinar.to_i + face_to_face.to_i).zero?
      error_message = "L'un des deux modes 'Webinaire' ou 'En présentiel' doivent être sélectionnés"
      errors.add(:webinar, error_message)
    end
  end
end