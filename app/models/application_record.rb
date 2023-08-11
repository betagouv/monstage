# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # use with trace :my_var, binding
  def trace(sym_var, binding)
    require 'pretty_console'
    var_value = eval(sym_var.to_s, binding)
    puts " "
    puts_with_orange_background " ---------------------------- "
    say_in_green_loudly "#{sym_var} = #{var_value}"
    puts_with_orange_background " ---------------------------- "
    puts " "
  end
end
