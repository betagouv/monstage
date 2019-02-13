# frozen_string_literal: true

class Credentials
  # usage: Credentials.enc(:db, :username) -> Rails.application.credentials[:test][:db][:username]
  def self.enc(*path, prefix_env: true)
    path = [Rails.env.to_sym].concat(path) if prefix_env
    value = Rails.application.credentials.dig(*path)
    notify_missing_value(path) unless value
    value
  end

  def self.notify_missing_value(path)
    error_message = "Missing key: #{path.join('.')}"

    raise ArgumentError, error_message unless Rails.env.production?
  end
end
