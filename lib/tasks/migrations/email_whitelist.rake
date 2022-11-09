require 'fileutils'
require 'pretty_console'

namespace :migrations do
  desc 'Migrate group_id to ministry_group table'
  task :email_whitelists_group_up, [] => :environment do |task, args|
    ActiveRecord::Base.transaction do
      EmailWhitelists::Ministry.all.each do |email_whitelist|
        ministry_group = MinistryGroup.create(
          group_id: email_whitelist.group_id,
          email_whitelist_id: email_whitelist.id
        )
      end
    end
    PrettyConsole.say_in_green 'task is finished'
  end
  
  desc 'Migrate group_id back to email_whitelist(in case of rollback)'
  task :email_whitelists_group_down, [] => :environment do |task, args|
    ActiveRecord::Base.transaction do
      MinistryGroup.all.each do |ministry_group|
        # with following code, group_id is set to the last occurence of a group with the same email_whitelist_id
        email_whitelist = EmailWhitelists::Ministry.find_by(id: ministry_group.email_whitelist_id)
        email_whitelist.update(group_id: ministry_group.group_id)
      end
    end
    PrettyConsole.say_in_green 'task is finished'
  end
end