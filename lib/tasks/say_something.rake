require 'pretty_console'
desc 'test task'
task :say_something, [:argument] => :environment do |t, args|
  3.times{ print '.'; sleep 0.5}
  puts 'Done'
  PrettyConsole.say_in_green(args.argument)
end