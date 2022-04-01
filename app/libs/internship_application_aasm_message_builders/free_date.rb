# frozen_string_literal: true

module InternshipApplicationAasmMessageBuilders
  class FreeDate < InternshipApplicationAasmMessageBuilder
    # for html formatted default message
    delegate :student,
             :internship_offer,
             to: :internship_application

    private

    def on_approved_message
      <<~HTML.strip
        <p>Bonjour #{student.presenter.formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est acceptée.</p>
        <p>Vous devez maintenant faire signer la convention de stage.</p>
      HTML
    end

    def on_rejected_message
      <<~HTML.strip
        <p>Bonjour #{student.presenter.formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est refusée.</p>
      HTML
    end

    def on_canceled_by_employer_message
      <<~HTML.strip
        <p>Bonjour #{student.presenter.formal_name},</p>
        <p>Votre candidature pour le stage "#{internship_offer.title}" est annulée.</p>
      HTML
    end

    def on_canceled_by_student_message
      <<~HTML.strip
        <p>#{internship_offer.employer.presenter.formal_name},</p>
        <p>Je ne suis pas en mesure d'accepter votre offre de stage
        "#{internship_offer.title}", car : </p>
      HTML
    end
  end
end
