require 'pretty_console.rb'

def open_files(dir, file_extensions)
  Dir["#{dir}/**/*"].each do |f|
    File.extname(f).in?(file_extensions) && File.open(f, 'r') do |file|
      yield file
    end
  end
end

def search_in_css_files
  css_highest_dir = Rails.root.join('app', 'front_assets', 'stylesheets')
  css_exts = ['.css', '.scss']
  open_files(css_highest_dir, css_exts) do |file|
    file.each_line do |line|
      next if line.blank?
      yield line
    end
  end
end

def search_in_files(var_names, ok_var = [])
  ext_names = ['.css', '.scss', '.js', '.jsx', '.slim', '.erb', '.rb', '.html', '.text']
  search_dirs = [ Rails.root.join('app'),
                  Rails.root.join('lib'),
                  Rails.root.join('test') ]
  var_names.each do |var_name|
    catch :too_many_matches do
      counter = 0
      search_dirs.each do |search_dir|
        open_files(search_dir, ext_names) do |file|
          file.each_line do |line|
            counter += 1 if line.include?(var_name)
          end
          throw :too_many_matches if counter > 1
        end
      end
      ok_var << var_name
    end # too_many_matches
  end
  ok_var
end

# -----------------------------------------------------------------------------

namespace :diet do
  desc 'check single use of css variable references'
  task fast_variables: :environment do
    var_names = []

    search_in_css_files do |line|
      if line.match?(/\s*(\$.*):/)
        var_names += line.scan(/(\$[[a-z]-_]*[^:])/).flatten
      end
    end
    ok_var = search_in_files(var_names.uniq)

    say_in_green ('Following variable names are not used in more than one file:')
    say_in_green (ok_var.flatten.uniq)
    puts "=> #{(ok_var.flatten.uniq).count} unused variable names"
  end

  desc 'check single use of css classes references'
  task fast_classes: :environment do
    class_names = []

    search_in_css_files do |line|
      captures = line.match(/\s*\.([a-z_-]*)|[^.]/).captures
      captures -= ['.'] if captures.include?('.')
      class_names += captures
    end
    class_names = class_names.compact.uniq

    say_in_green "#{class_names.count} classes found"
    puts 'Start searching for classes'

    ok_var = search_in_files(class_names)

    say_in_green ('Following classes are not used in more than one file:')
    say_in_green (ok_var.flatten.uniq)
    puts "=> #{(ok_var.flatten.uniq).count} unused classes names"
    puts "Be careful about classes used in third party code, like iframes for video players"
  end
end