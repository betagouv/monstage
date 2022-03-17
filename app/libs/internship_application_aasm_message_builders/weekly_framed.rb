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
        <p>Bonjour #{Presenters::User.new(student).formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est acceptée pour la semaine #{week.short_select_text_method}.</p>
        <p>Vous devez maintenant faire signer la convention de stage.</p>
      HTML
    end

    def on_rejected_message
      ""
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
