module Presenters
  class Signature < User
    def show_code
      [user.signature_phone_token[0..2], user.signature_phone_token[3..-1]].join(' ')
    end
  end
end