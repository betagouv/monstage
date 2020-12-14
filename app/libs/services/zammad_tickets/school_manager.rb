module Services
  module ZammadTickets
    class SchoolManager < ZammadTicket
      def internship_leading_sentence
        'Demande de stage à distance'
      end

      def template_file_name
        'employer_ticket.text.erb'
      end
    end
  end
end
