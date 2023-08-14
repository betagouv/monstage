module Utilities
  # use with trace :my_var, binding
  def trace(sym_var, binding)
    require 'pretty_console'
    include PrettyConsole
    var_value = eval(sym_var.to_s, binding)
    puts " "
    puts_with_orange_background " ---------------------------- "
    puts " "
    puts_in_green_loudly "#{sym_var} = #{var_value}"
    puts " "
    puts_with_orange_background " ---------------------------- "
    puts " "
  end
end