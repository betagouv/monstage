module Finders
  class TabEmployer
    def pending_agreements_count
      user.internship_agreements
          .draft
          .count
    end

    private

    attr_reader :user

    def initialize(user:)
      @user = user
    end
  end
end
