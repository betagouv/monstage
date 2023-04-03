# frozen_string_literal: true
require 'fileutils'
require 'pretty_console'

namespace :users do
  desc 'Remove all information about a user (RGPD)'
  task :delete_user, [:user_id] => :environment do |task, args|
    user_id = args.user_id

    puts "Removing all information about user #{user_id}..."

    user = User.find(user_id)
    user.anonymize

    puts 'done'
  end


  desc 'Description of employers and internship_offers to anonymize'
  task :describe_idle_employers, [:school_year] => [:environment] do |t, args|
    school_year = args.school_year || (Date.today - 2.years).year
    trigerring_date = Date.new(school_year.to_i, 9, 1)

    reconnected_employers_ids = Users::Employer.kept
                    .where.not(confirmed_at: nil)
                    .where('current_sign_in_at >= ?', trigerring_date)
                    .ids
    puts "reconnected_employers_ids #{reconnected_employers_ids.count}"
    identified_exceptions_ids = Users::Operator.ids
    puts "identified_exceptions_ids #{identified_exceptions_ids.count}"
    in_white_list = reconnected_employers_ids + identified_exceptions_ids
    employers = Users::Employer.kept.where.not(id: in_white_list)

    targeted_fields = %i[email id type role first_name last_name confirmed_at current_sign_in_at last_sign_in_at]
    CSV.open("tmp/export_idle_employers.csv", "w", force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
      csv << [].concat(targeted_fields, ['environment'])

      employers.each do |user|
        csv << [
                user.email,
                user.id,
                user.type,
                user.role,
                user.first_name,
                user.last_name,
                user.confirmed_at,
                user.current_sign_in_at,
                user.last_sign_in_at,
                'production']
      end
    end

    offers = InternshipOffer.includes(:employer).published.kept.where(employer_id: employers.ids)
    targeted_fields = %i[title id employer_first_name employer_last_name employer_email published_at createad_at updated_at last_date alert]
    CSV.open("tmp/export_idle_employers_offers.csv", "w", force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
      csv << [].concat(targeted_fields, ['environment'])

      offers.each do |offer|
        alert = offer.last_date > Date.today ? 'take a look' : 'no alert'
        csv << [
                offer.title,
                offer.id,
                offer.employer.first_name,
                offer.employer.last_name,
                offer.employer.email,
                offer.published_at,
                offer.created_at,
                offer.updated_at,
                offer.last_date,
                alert,
                'production']
      end
    end
  end

  desc 'Anonymize idle employers from a specific school year'
  task :delete_idle_employers, [:school_year] => [:environment] do |t, args|
    school_year = args.school_year || (Date.today - 2.years).year
    trigerring_date = Date.new(school_year.to_i, 9, 1)

    if trigerring_date.is_a?(Date) && (trigerring_date < Date.today - 1.year)
      reconnected_employers_ids = Users::Employer.kept
                      .where.not(confirmed_at: nil)
                      .where('current_sign_in_at >= ?', trigerring_date)
                      .ids
      puts "reconnected_employers_ids #{reconnected_employers_ids.count}"
      identified_exceptions_ids = Users::Operator.ids
      puts "identified_exceptions_ids #{identified_exceptions_ids.count}"
      in_white_list = reconnected_employers_ids + identified_exceptions_ids
      employers = Users::Employer.kept.where.not(id: in_white_list)
      puts "Ready to anonymize #{employers.count}"
      employers.each do |employer|
        puts "##{employer.id} | "
        sleep 0.3
        RemoveIdleEmployersJob.new.perform(employer_id: employer.id)
      end
      if employers.size.zero?
        puts "nothing to do"
      else
        puts "idle employers from september 1st #{school_year} are anonymized"
      end
    else
      puts "this year is too early"
    end

  end

  # launch with rake "delete_false_employers[2019]" to
  # anonymize false employers from 2019-2020 school year
  desc 'Anonymize false employers from a specific school year'
  task :delete_false_employers, [:school_year] => [:environment] do |t, args|
    school_year = args.school_year || (Date.today - 2.years).year
    trigerring_date = Date.new(school_year.to_i, 9, 1)
    employer_trash_list = []
    white_list_ids = [28049, 37605, 44106, 46922, 46927, 47953, 49770]

    employers = Users::Employer.where('created_at >= ? ', trigerring_date)
                              .where('created_at <= ? ', trigerring_date + 1.year)
                              .kept
    PrettyConsole.say_with_leight_background("Starting to delete false employers within ##{employers.count} employers")

    employers.each do |employer|
      next if employer.id.in?(white_list_ids)

      catch :next_employer do
        [employer.first_name, employer.last_name].each do |field|
          field.split(/[- ]/) do |sub_field|
            two_upcases = sub_field.match?(/.*[A-Z].*[A-Z].*/) && sub_field.match?(/.*[a-z].*[a-z].*/)
            # 2 upcases in the middle of the word || 5 successive consonants
            if two_upcases || sub_field.match?(/.*([^aeioyuôéèî@0-9]{5,}).*/i)
              employer_trash_list << employer.id
              puts "id_employer : #{employer.id} | ko field: #{field} | #{employer.first_name} | #{employer.last_name} | #{employer.email} | #{employer.created_at}"
              throw :next_employer
            end
          end
        end
      end
    end


    PrettyConsole.say_in_red "Ready to anonymize #{employer_trash_list.count} employers"
    associated_offers = InternshipOffer.where(employer_id: employer_trash_list)
    unless associated_offers.empty?
      PrettyConsole.say_in_blue "Associated offers count : #{associated_offers.count}"
      associated_offers.each do |offer|
        puts "id_employer : #{offer.employer_id} | #{offer.title} | #{offer.created_at}"
        puts "#{offer.employer.first_name} #{offer.employer.last_name} | #{offer.employer.email}"
        puts "--------------------------------"
        puts " "
      end
    end

    if associated_offers.empty? && !employer_trash_list.empty?
      employer_trash_list.uniq.each do |employer_id|
        User.find_by(id: employer_id).anonymize(send_email: false)
        print "."
      end
      puts ""
    end

    PrettyConsole.say_with_leight_background("Done")
  end
end
