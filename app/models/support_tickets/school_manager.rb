module SupportTickets
  class SchoolManager < SupportTicket
    attr_accessor :school_id,
                  :students_quantity,
                  :class_rooms_quantity

    validates :class_rooms_quantity,
              presence: {
                message: 'Il manque à cette demande le nombre d\'étudiants concernés'
              }
    validates :students_quantity,
              numericality: {
                only_integer: true,
                message: "le nombre d'étudiants devrait être chiffré"
              }
    def send_to_support
      SupportTicketJobs::SchoolManager
        .perform_later(params: self.as_json.symbolize_keys)
    end
  end
end