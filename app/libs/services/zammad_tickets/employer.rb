module Services
  module ZammadTickets
    class Employer < ZammadTicket
      def ticket_payload
        subject = 'Proposition de stage à distance'
        subject = "#{subject} | webinar" if @params[:webinar].to_i == 1
        subject = "#{subject} | présentiel" if @params[:face_to_face].to_i == 1
        subject = "#{subject} | semaine de stage digitale" if @params[:digital_week].to_i == 1

        message = "nombre d'intervenants proposés : #{@params[:speechers_quantity]}\n" \
                  "nombre de métiers abordés: #{@params[:business_lines_quantity]}\n" \
                  "-------------------------------------\n" \
                  "dates visées :\n #{human_week_desc @params[:week_ids]}\n" \
                  "-------------------------------------\n" \
                  "Entreprise du PaQte: #{@params[:paqte].to_i == 1 ? 'oui' : 'non'}\n" \
                  "=====================================\n" \
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