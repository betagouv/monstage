Feedjira.configure do |config|
  config.parsers = [
    Feedjira::Parser::RSS,
    Feedjira::Parser::ITunesRSS,
  ]
end