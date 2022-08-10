module PrettyConsole
  def self.say_in_red(str)
    puts "\e[31m=====> #{str} <=====\e[0m"
  end
  def self.say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
  def self.say_in_yellow(str)
    puts "\e[33m=====> #{str} <=====\e[0m"
  end
  def self.say_in_blue(str)
    puts "\e[34m=====> #{str} <=====\e[0m"
  end
  def self.say_in_purple(str)
    puts "\e[35m=====> #{str} <=====\e[0m"
  end
  def self.say_in_cyan(str)
    puts "\e[36m=====> #{str} <=====\e[0m"
  end
  def self.say_in_heavy_white(str)
    puts "\e[37m=====> #{str} <=====\e[0m"
  end

  # with backgrounds
  
  def self.say_with_leight_background(str)
    puts "\e[40m=====> #{str} <=====\e[0m"
  end
  def self.say_with_red_background(str)
    puts "\e[41m=====> #{str} <=====\e[0m"
  end
  def self.say_with_green_background(str)
    puts "\e[42m=====> #{str} <=====\e[0m"
  end
  def self.say_with_orange_background(str)
    puts "\e[43m=====> #{str} <=====\e[0m"
  end
  def self.say_with_blue_background(str)
    puts "\e[44m=====> #{str} <=====\e[0m"
  end
  def self.say_with_purple_background(str)
    puts "\e[45m=====> #{str} <=====\e[0m"
  end
  def self.say_with_white_background(str)
    puts "\e[47m=====> #{str} <=====\e[0m"
  end
end
