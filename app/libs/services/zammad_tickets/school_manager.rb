module Services
  module ZammadTickets
    class SchoolManager < ZammadTicket
      def internship_leading_sentence
        'Demande de stage à distance'
      end

      def message
        "nombre de classes visées : #{@params[:class_rooms_quantity]}\n" \
        "nombre d'élèves visés: #{@params[:students_quantity]}\n" \
        "-------------------------------------\n" \
        "dates visées :\n #{human_week_desc @params[:week_ids]}\n" \
        "-------------------------------------\n" \
        "MESSAGE : \n#{@params[:message]}"
      end
    end
  end
end