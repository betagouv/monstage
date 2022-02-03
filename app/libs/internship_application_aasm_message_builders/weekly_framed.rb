# frozen_string_literal: true

module InternshipApplicationAasmMessageBuilders
  class WeeklyFramed < InternshipApplicationAasmMessageBuilder
    # for html formatted default message
    delegate :student,
             :internship_offer,
             :week,
             to: :internship_application

    private

    def on_approved_message
      <<~HTML.strip
        <p style="{font-size: '42px'}">Bonjour #{student.first_name},</p>
        <p>Bonne nouvelle <span class="emoticon">&#127881;</span> ! </p>
        <p>Votre candidature pour le stage "#{internship_offer.title} " 
        est acceptée pour la semaine #{week.short_select_text_method}. 
        Qu’est-ce qu’il faut faire maintenant ?</p>
        <p>
          <ul>
            <ol>
              <strong>
                <span class="emoticon" style="font-size:20px">&#10004;</span> 
                Confirmer
              </strong>
               à l’employeur votre intérêt pour le stage et l'envoi sous peu de la convention de stage. Ne répondez pas à ce mail, mais utilisez plutôt les coordonnées listées plus bas dans le mail.
            </ol>
            <ol>
              <strong>
                <span class="emoticon" style="font-size:20px">&#9999;</span>
                Faire signer
              </strong>
              la convention de stage à votre établissement : elle est fournie par votre établissement et doit d’abord être signée par vos parents (ou autres responsables légaux).
            </ol>
            <ol>
              <strong>
                  <span class="emoticon" style="font-size:20px">&#128231;</span> 
                  Transmettre
              </strong>
               à l’employeur une copie de la convention de stage, par courrier, email ou en mains propres.
            </ol>
          </ul>
        </p>
        <p>
          <span style="font-decoration:underline">Attention</span> : sans convention convenablement remplie et signée, le stage ne peut pas avoir lieu. 
          <span class="emoticon" style="font-size:20px">&#x26a0;&#xfe0f;</span> 
        </p>
        <p>
          <strong>Rappel des coordonnées de votre employeur/tuteur : </<strong>
        </p>
          #{internship_offer.employer_name}
          <br/>
          #{internship_offer.street}
          <br/>
          #{internship_offer.zipcode} #{internship_offer.city}
        <p>
          <strong>Votre Contact du tuteur :</strong>
        </p>
        </p>
          #{internship_offer.tutor_name}
          <br/>
          #{internship_offer.tutor_email}
          <br/>
          #{ Presenters::User.new(OpenStruct.new(phone: internship_offer.tutor_phone)).pretty_phone_number }
        <p>
        <p>
          Dernière ligne droite avant le stage !
        </p>
        <p>
          À très bientôt,
        </p>
        <p>
        L’équipe Mon Stage de 3e.
        </p>
      HTML
    end

    def on_rejected_message
      <<~HTML.strip
        <p>Bonjour #{Presenters::User.new(student).formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est refusée pour la semaine #{week.short_select_text_method}.</p>
      HTML
    end

    def on_canceled_by_employer_message
      <<~HTML.strip
        <p>Bonjour #{Presenters::User.new(student).formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est annulée pour la semaine #{week.short_select_text_method}.</p>
      HTML
    end

    def on_canceled_by_student_message
      <<~HTML.strip
        <p>#{internship_offer.employer.formal_name},</p>
        <p>Je ne suis pas en mesure d'accepter votre offre de stage
        "#{internship_offer.title}" prévu pour la semaine
        #{week.short_select_text_method}, car : </p>
      HTML
    end
  end
end
