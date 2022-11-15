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
  COLOR_MAP.keys.each do |color|
    # say_in_red('Hello World')
    define_singleton_method(
      "say_in_#{color}".to_sym,
      Proc.new do |str|
        console_in_color(COLOR_MAP, enhance_str(str), color)
      end
    )
    # puts_in_red('Hello World')
    define_singleton_method(
      "puts_in_#{color}".to_sym,
      Proc.new do |str|
        console_in_color(COLOR_MAP, str, color)
      end
    )
  end
  BACKGROUND_COLOR_MAP.keys.each do |color|
    # say_with_leight_background('Hello World')
    define_singleton_method(
      "say_with_#{color}_background".to_sym,
      Proc.new do |str|
        console_in_color(BACKGROUND_COLOR_MAP, enhance_str(str), color)
      end
    )
    # puts_with_red_background('Hello World')
    define_singleton_method(
      "puts_with_#{color}_background".to_sym,
      Proc.new do |str|
        console_in_color(BACKGROUND_COLOR_MAP, str, color)
      end
    )
  end

  def self.enhance_str(str)
    "=====> #{str} <====="
  end

  def self.console_in_color(map, str, color)
    puts "\e[#{map[color.to_sym]}m#{str}\e[0m"
  end

end
