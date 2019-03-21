module Presenters
  class User
    def full_name
      "#{user.first_name} #{user.last_name}"
    end

    def role_name
      user.model_name.human
    end

    private
    attr_reader :user
    def initialize(user:)
      @user = user
    end
  end
end
