# frozen_string_literal: true

class SwitchUser
  def self.enable(user:, cookies:)
    cookies[:switch_user] = user.id
    yield
  end

  def self.disable(cookies:)
    switch_back = cookies[:switch_user]
    return if switch_back.nil?

    user = User.find(switch_back)
    cookies.delete(:switch_user)
    yield(user)
  end
end
