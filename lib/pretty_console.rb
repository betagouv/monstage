module PrettyConsole
  COLOR_MAP = {
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    purple: 35,
    cyan: 36,
    heavy_white: 37
  }
  BACKGROUND_COLOR_MAP = {
    leight: 40,
    red: 41,
    green: 42,
    orange: 43,
    blue: 44,
    purple: 45,
    cyan: 46,
    white: 47
  }
  # say_in_red('Hello World')
  COLOR_MAP.keys.each do |color|
    define_singleton_method(
      "say_in_#{color}".to_sym,
      Proc.new do |str|
        puts "\e[#{COLOR_MAP[color.to_sym]}m=====> #{str} <=====\e[0m"
      end
    )
  end
  BACKGROUND_COLOR_MAP.keys.each do |color|
    define_singleton_method(
      "say_with_#{color}_background".to_sym,
      Proc.new do |str|
        puts "\e[#{BACKGROUND_COLOR_MAP[color.to_sym]}m=====> #{str} <=====\e[0m"
      end
    )
  end

  # only puts
  COLOR_MAP.keys.each do |color|
    define_singleton_method(
      "puts_in_#{color}".to_sym,
      Proc.new do |str|
        puts "\e[#{COLOR_MAP[color.to_sym]}m#{str}\e[0m"
      end
    )
  end
  BACKGROUND_COLOR_MAP.keys.each do |color|
    define_singleton_method(
      "puts_with_#{color}_background".to_sym,
      Proc.new do |str|
        puts "\e[#{BACKGROUND_COLOR_MAP[color.to_sym]}m#{str}\e[0m"
      end
    )
  end
end
