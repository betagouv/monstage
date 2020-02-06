# frozen_string_literal: true

module Users
  class Visitor < User
    def readonly?
      true
    end
  end
end
