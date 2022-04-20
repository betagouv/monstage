module EmailUtils
  def self.env_host
    ENV.fetch('HOST') { 'https://test.example.com' }
  end

  def self.domain
    URI(env_host).host.split('.').last(2).join('.')
  end

  def self.from
    return 'support@monstagedetroisieme.fr' if Rails.env.review?

    "support@#{URI(env_host).host.gsub(/^www\./, '')}"
  end

  def self.display_name
    'Mon Stage de 3e'
  end

  def self.formatted_email
    address = Mail::Address.new
    address.address = from
    address.display_name = display_name
    address.format
  end
end
