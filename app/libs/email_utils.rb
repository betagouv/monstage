module EmailUtils
  def self.from
    domain_without_www = URI(env_host).host.gsub('www.', '')
    "support@#{domain_without_www}"
  end

  def self.env_host
    ENV.fetch('HOST') { 'https://test.example.com' }
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
