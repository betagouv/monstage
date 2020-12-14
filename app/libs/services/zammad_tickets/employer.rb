module Services
  module ZammadTickets
    class Employer < ZammadTicket

      def internship_leading_sentence
        'Proposition de stage à distance'
      end
      

      def message
        "nombre d'intervenants proposés : #{@params[:speechers_quantity]}\n" \
        "nombre de métiers abordés: #{@params[:business_lines_quantity]}\n" \
        "-------------------------------------\n" \
        "dates visées :\n #{human_week_desc @params[:week_ids]}\n" \
        "-------------------------------------\n" \
        "Entreprise du PaQte: #{@params[:paqte].to_i == 1 ? 'oui' : 'non'}\n" \
        "=====================================\n" \
        "MESSAGE : \n#{@params[:message]}"
      end
    end
  end
end