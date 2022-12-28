module InternshipAgreements
  class BaseComponent < ApplicationComponent
    include Turbo::FramesHelper,
            Turbo::Streams::StreamName,
            Turbo::Streams::Broadcasts

    delegate :main_teacher_accept_terms?,
             :school_manager_accept_terms?,
             :employer_accept_terms?,
             to: :internship_agreement,
             allow_nil: true

    def ready_to_print?
      signed_count == required_signatures_count
    end

    def signed_count
      required_signatures.map { |attr_name| self.send("#{attr_name}") }
                         .select { |value| value == true}
                         .size
    end

    def required_signatures_count
      required_signatures.size
    end

    def required_signatures
      [
        :employer_accept_terms?,
        :school_manager_accept_terms?
      ]
    end
  end
end
