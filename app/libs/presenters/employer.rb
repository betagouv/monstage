module Presenters
  class Employer < User

    private
    attr_reader :user

    def initialize(employer)
      @user = employer
    end
  end
end
