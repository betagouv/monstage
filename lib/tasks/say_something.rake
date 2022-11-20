require 'pretty_console'
desc 'test task'
task :say_something, [:argument] => :environment do |t, args|
  PrettyConsole.say_in_green(args.argument)
end