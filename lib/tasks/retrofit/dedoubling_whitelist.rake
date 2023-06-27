require 'pretty_console.rb'
# usage : rake retrofit:internship_agreements_creations

namespace :retrofit do
  desc 'Retrofit du doublon de whitelist in ministry'
  task :whitelist_dedoubling, [:email, :type, :id_to_remove] => :environment do |t, args|
    # use with rake "retrofit:whitelist_dedoubling[email@domain.fr, Ministry, id_to_remove]"
    email        = args.email
    type         = args.type
    id_to_remove = args.id_to_remove

    PrettyConsole.say_in_green "Starting #{email} as #{args.type}"
    ActiveRecord::Base.transaction do
      klass = "EmailWhitelists::#{args.type}".constantize
      whitelists = klass.where(email: email)
      user_id = User.find_by(email: email).id
      if whitelists.count > 1
        PrettyConsole.say_in_yellow "Found #{whitelists.count} duplicates for #{email} as #{args.type}"
        white_list_to_remove = klass.find_by(id: id_to_remove)
        groups_to_keep = white_list_to_remove.groups
        white_list_to_remove.destroy

        white_list = klass.find_by(email: email)
        white_list.groups += groups_to_keep
        white_list.save
        User.find_by(id: user_id).undiscard
      end
    end
    PrettyConsole.say_in_green "Done #{email} as #{args.type}"
  end
end