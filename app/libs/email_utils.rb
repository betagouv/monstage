module EmailUtils
  def self.env_host
    ENV.fetch('HOST') { 'https://www.monstagedetroisieme.fr' }
  end

  def self.domain
    URI(env_host).host.split('.').last(2).join('.')
  end

  def self.from
    "notification@monstagedetroisieme.fr"
  end

  def self.formatted_from
    formatted_email(from)
  end

  def self.reply_to
    "ne-pas-repondre@monstagedetroisieme.fr"
  end

  def self.formatted_reply_to
    formatted_email(reply_to)
  end


  def self.display_name
    'Mon Stage de 3e'
  end

  def self.formatted_email(email)
    address = Mail::Address.new
    address.address = email
    address.display_name = display_name
    address.format
  end
end
