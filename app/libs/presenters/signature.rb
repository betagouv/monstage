module Presenters
  class Signature
    def signed_at
      "Signé le #{I18n.l signature.signature_date, format: '%d %B %Y à %Hh%M'}"
    end

    private

    attr_reader :signature

    def initialize(signature: )
      @signature = signature
    end
  end
end