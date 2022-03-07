module Presenters
  class InternshipApplication

    def label_set
      case code
      when :approve_code
        {
          modal_code_to_fr: 'Accepter',
          premodal_sentence: 'Accepter',
          modal_legend: 'Message d\'accompagnement'
        }

      when :reject_code
        {
          modal_code_to_fr: 'Refuser',
          premodal_sentence: "Une fois la candidature refusée, un email de notification " \
                              "va être envoyé à l'élève avec le motif du refus.",
          modal_legend: "Motif du refus"
        }

      when :cancel_code
        {
          modal_code_to_fr: 'Annuler',
          premodal_sentence: '',
          modal_legend: "Motif de l'annulation"
        }

      when :cancel_by_employer_code
        {
          modal_code_to_fr: 'Annuler',
          premodal_sentence: "Une fois la candidature annulée, un email de notification " \
                              "va être envoyé à l'élève avec le motif de l'annulation.",
          modal_legend: "Motif de l'annulation"
        }

      else
        raise("unknown code in internship application's presenter's label_set")
      end
    end



    private
    attr_reader :internship_application, :code

    def initialize(internship_application, code=nil)
      @internship_application = internship_application
      @code = code
    end
  end
end
