module Services
  module ZammadTickets
    class SchoolManager < ZammadTicket
      def ticket_payload
        subject = 'Demande de stage à distance'
        subject = "#{subject} | webinar" if @params[:webinar].to_i == 1
        subject = "#{subject} | présentiel" if @params[:face_to_face].to_i == 1
        subject = "#{subject} | semaine de stage digitale" if @params[:digital_week].to_i == 1

        message = "nombre de classes visées : #{@params[:class_rooms_quantity]}\n" \
                  "nombre d'élèves visés: #{@params[:students_quantity]}\n" \
                  "-------------------------------------\n" \
                  "dates visées :\n #{human_week_desc @params[:week_ids]}\n" \
                  "-------------------------------------\n" \
                  "MESSAGE : \n#{@params[:message]}"
        {
          "title": subject,
          "group": 'Users',
          "customer": @user.email,
          "article": {
            "subject": subject,
            "body": message,
            "type": 'note',
            "internal": false
          },
          "note": 'Stages à distance'
        }
      end
    end
  end
end