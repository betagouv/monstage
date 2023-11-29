class UrlShrinker < ApplicationRecord
  belongs_to :user

  def self.short_url(url:, user_id:)
    url_shrinker = add(url: url, user_id: user_id)
    Rails.application
         .routes
         .url_helpers
         .o_url_shrinker_url(id: url_shrinker.url_token, **Rails.configuration.action_mailer.default_url_options )
  end

  def self.remove(id:)
    UrlShrinker.find(id).destroy
  end

  def self.fetch(url_token:)
    UrlShrinker.find_by(url_token: url_token)
  end

  def increment_clicks!
    self.click_count += 1
    save!
  end


  private

  def self.add(url:, user_id:)
    url_token = generate_url_token
    while(url_token_exists?(url_token: url_token)) do
      url_token = generate_url_token
    end
    UrlShrinker.create!(
      original_url: url,
      user_id: user_id,
      url_token: url_token
    )
  end

  def self.generate_url_token
    SecureRandom.base36(5)
  end

  def self.url_token_exists?(url_token:)
    UrlShrinker.where(url_token: url_token).exists?
  end
end
