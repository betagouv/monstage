module Finders
  class TabEmployer
    def pending_agreements_count
      # internship_agreement draft
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
