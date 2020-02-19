# frozen_string_literal: true

# see: https://weblog.rubyonrails.org/2019/2/22/zeitwerk-integration-in-rails-6-beta-2/
autoloader = Rails.autoloaders.main
sti_leaves = %w[employer god main_teacher operator other school_manager student teacher]

sti_leaves.each do |leaf|
  autoloader.preload("#{Rails.root}/app/models/users/#{leaf}.rb")
end
