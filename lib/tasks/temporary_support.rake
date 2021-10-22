namespace :support do
  desc 'set Tutor to specific User for LEPC'
  task :set_specific_tutor, [] => :environment do
    tutor_email = 'winnie.silva@lereseau.fr'

    say_in_green "Starting ..."
    process(tutor_email)
    say_in_green 'task is finished'
  end

  def process(tutor_email)
    tutor = User.find_by_email(tutor_email)
    return unless tutor.present?

    operator_internship_offers = InternshipOffer.kept.in_the_future.where(employer_id: tutor.id)
    InternshipOffer.transaction do
      operator_internship_offers.each do |offer|
        offer.tutor_name = 'Winnie Silva'
        offer.tutor_email = tutor_email
        offer.tutor_phone = nil

        offer.save!
        say_in_green '.'
      end
    end
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end