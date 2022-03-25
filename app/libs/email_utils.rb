module EmailUtils
  def self.from
    return "support@monstagedetroisieme.fr" if Rails.env.review?

    host_or_default = ENV.fetch('HOST') { 'https://test.example.com' }
    domain_without_www = URI(host_or_default).host.gsub('www.', '')
    "support@#{domain_without_www}"
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
