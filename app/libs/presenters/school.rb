module Presenters
  class School
    def select_text_method
      "#{name} - #{city} - #{zipcode}"
    end

    def agreement_address
      "Collège #{name} - #{city}, #{zipcode}"
    end
  end
end