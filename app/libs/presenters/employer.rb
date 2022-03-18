module Presenters
  class Employer
    include Humanable

    private
    attr_reader :user

    def initialize(employer)
      @user = employer
    end
  end
end
