require 'pretty_console.rb'
namespace :diet do
  desc 'check single use of css variable references'
  task fast: :environment do
    css_highest_dir= Rails.root.join('app', 'front_assets', 'stylesheets')
    var_names   = []
    ok_var   = []
    ext_names   = ['.css', '.scss', '.js', '.jsx', '.slim', '.erb', '.rb', '.html']
    search_dirs = [Rails.root.join('app'),
                    Rails.root.join('lib'),
                    Rails.root.join('test')
                  ]

    Dir["#{css_highest_dir}/**/*"].each do |f|
      next if File.extname(f).nil?

      if File.extname(f).in?(['.css', '.scss'])
        File.open(f, 'r') do |file|
          file.each_line do |line|
            if line.match?(/\s*(\$.*):/)
              var_names += line.scan(/(\$[[a-z]-_]*[^:])/).flatten
            end
          end
        end
      end
    end
    var_names = var_names.uniq

    var_names.each do |var_name|
      catch :too_many_matches do
        counter = 0
        search_dirs.each do |search_dir|
          Dir["#{search_dir}/**/*"].each do |f|
            File.extname(f).in?(ext_names) && File.open(f, 'r') do |file|
              file.each_line do |line|
                counter += 1 if line.include?(var_name)
              end
              throw :too_many_matches if counter > 1
            end
          end
          puts counter if counter > 1
        end
        ok_var << var_name
      end # too_many_matches
    end
    say_in_green ('Following variable names are not used in more than one file:')
    say_in_green (ok_var.flatten.uniq)
    say_in_green (ok_var.flatten.uniq).count

  end

  desc 'check single use of css classes references'
  task fast_classes: :environment do
    css_exts = ['.css', '.scss']
    css_highest_dir= Rails.root.join('app', 'front_assets', 'stylesheets')
    class_names   = []
    ok_var   = []
    ext_names   = ['.css', '.scss', '.js', '.jsx', '.slim', '.erb', '.rb', '.html']
    search_dirs = [Rails.root.join('app'),
                    Rails.root.join('lib'),
                    Rails.root.join('test')
                  ]

    Dir["#{css_highest_dir}/**/*"].each do |f|
      next if File.extname(f).nil?

      if File.extname(f).in?(css_exts)
        File.open(f, 'r') do |file|
          file.each_line do |line|
            captures = line.match(/\s*\.([a-z_-]*)|[^.]/).captures
            captures -= ['.'] if captures.include?('.')
            class_names += captures
          end
        end
      end
    end
    class_names = class_names.compact.uniq

    say_in_green class_names.count

    say_in_green('Start searching for classes')

    file_count = 0

    class_names.each do |class_name|
      catch :too_many_matches do
        counter = 0
        search_dirs.each do |search_dir|
          Dir["#{search_dir}/**/*"].each do |f|
            next if File.extname(f).blank?
            File.extname(f).in?(ext_names) && File.open(f, 'r') do |file|
              file_count +=1
              file.each_line do |line|
                counter += 1 if line.include?(class_name)
              end
              throw :too_many_matches if counter > 1
            end
          end
          puts counter if counter > 1
        end
        ok_var << class_name
      end # too_many_matches
    end
    say_in_green ('Following classes are not used in more than one file:')
    say_in_green (ok_var.flatten.uniq)
    say_in_green (ok_var.flatten.uniq).count

    say_in_green file_count

  end
end