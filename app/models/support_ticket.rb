class SupportTicket
  include ActiveModel::Model

  attr_accessor :user_id,
                :school_id,
                :message,
                :webinar,
                :face_to_face,
                :subject,
                :digital_week,
                :students_quantity,
                :class_rooms_quantity,
                :week_ids

  validates :class_rooms_quantity,
            presence: {
              message: 'Il manque à cette demande le nombre d\'étudiants concernés'
            }
  validates :students_quantity,
            numericality: {
              only_integer: true,
              message: "le nombre d'étudiants devrait être chiffré"
            }
  validate :one_mode_minimum
  validate :one_week_at_least

  private

  def one_mode_minimum
    if (webinar.to_i + face_to_face.to_i + digital_week.to_i).zero?
      error_message = "L'un des trois modes 'Semaine digitale', 'Webinaire' " \
                      "ou 'En présentiel' doivent être sélectionnés"
      errors.add(:webinar, error_message)
    end
  end

  def one_week_at_least
    if !week_ids.is_a?(Array) || week_ids.empty?
      error_message = "Il faudrait sélectionner au moins une semaine " \
                      "cible pour vos étudiants"
      errors.add(:week_ids, error_message)
    end
  end
end