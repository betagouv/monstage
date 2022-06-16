require 'open-uri'
require 'net/https'

if Rails.env.review?
  module Net
    class HTTP
      alias_method :original_use_ssl=, :use_ssl=

      def use_ssl=(flag)
        # heroku :  `openssl version -a` gives that path
        self.ca_file = '/usr/lib/ssl'
        self.verify_mode = OpenSSL::SSL::VERIFY_PEER
        self.original_use_ssl = flag
      end
    end
  end
end