require 'pretty_console.rb'
# usage : rake retrofit:internship_agreements_creations

include PrettyConsole
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

  desc 'Retrofit du doublon d\'établissement'
  task :school_dedoubling, [:old_school_id, :new_school_id] => :environment do |t, args|
    # use with ```rake "retrofit:school_dedoubling[old_school_id, new_school_id]"``` in console

    old_school_id = args.old_school_id
    new_school_id = args.new_school_id

    PrettyConsole.say_in_green "Starting school dedoubling #{old_school_id} ==> #{new_school_id}"
    ActiveRecord::Base.transaction do
      old_school = School.find(old_school_id)
      new_school = School.find(new_school_id)
      PrettyConsole.say_in_yellow "Found #{old_school.name} and #{new_school.name} for #{old_school_id} and #{new_school_id}"

      if old_school && new_school
        ClassRoom.where(school_id: old_school_id).update_all(school_id: new_school_id)
        HostingInfo.where(school_id: old_school_id).update_all(school_id: new_school_id)
        Identity.where(school_id: old_school_id).update_all(school_id: new_school_id)
        InternshipAgreementPreset.where(school_id: old_school_id).update_all(school_id: new_school_id)
        InternshipOfferInfo.where(school_id: old_school_id).update_all(school_id: new_school_id)
        # InternshipOfferStudentInfo.where(school_id: old_school_id).update_all(school_id: new_school_id)
        InternshipOffer.where(school_id: old_school_id).update_all(school_id: new_school_id)
        SchoolInternshipWeek.where(school_id: old_school_id).update_all(school_id: new_school_id)
        User.where(school_id: old_school_id).update_all(school_id: new_school_id)

        old_school.destroy

        new_school.reload.class_rooms.select(:name).group(:name).having('count(*) > 1').each do |class_room|
          class_room_ids = new_school.class_rooms.where(name: class_room.name).pluck(:id)
          kept_class_room_id = class_room_ids.shift
          Users::Student.where(class_room_id: class_room_ids).update_all(class_room_id: kept_class_room_id)
          ClassRoom.where(id: class_room_ids).destroy_all
        end
      end
    end
    PrettyConsole.say_in_green "Done school dedoubling #{old_school_id} ==> #{new_school_id}"
  end
end