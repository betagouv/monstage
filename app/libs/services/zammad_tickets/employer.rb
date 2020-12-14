module Services
  module ZammadTickets
    class Employer < ZammadTicket
      def internship_leading_sentence
        'Proposition de stage à distance'
      end

      def template_file_name
        'school_manager_ticket.text.erb'
      end
    end
  end
end
