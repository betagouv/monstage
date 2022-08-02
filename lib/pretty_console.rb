module PrettyConsole
  def self.say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end
