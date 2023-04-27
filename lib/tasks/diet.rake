require 'pretty_console.rb'

def open_files(dir, file_extensions)
  Dir["#{dir}/**/*"].each do |f|
    File.extname(f).in?(file_extensions) && File.open(f, 'r') do |file|
      yield file
    end
  end
end

def line_in_files(dir, file_extensions)
  open_files(dir, file_extensions) do |file|
    file.each_line do |line|
      next if line.blank?
      yield line
    end
  end
end

def search_in_css_files
  css_highest_dir = Rails.root.join('app', 'front_assets', 'stylesheets')
  css_exts = ['.css', '.scss']
  line_in_files(css_highest_dir, css_exts) do |line|
    yield line
  end
end

def search_in_ruby_files
  ruby_highest_dir = Rails.root
  ruby_exts = ['.rb', '.rake']
  line_in_files(ruby_highest_dir, ruby_exts) do |line|
    yield line
  end
end


def search_in_files(var_names, search_domain , valid_file_extension_list = [], ok_var = [])
  var_names.each do |var_name|
    catch :too_many_matches do
      counter = 0
      search_domain.each do |search_dir|
        open_files(search_dir, valid_file_extension_list) do |file|
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

def communication_over_objects_to_find(count, word_in_plural)
  PrettyConsole.say_in_green "#{count} #{word_in_plural} found"
  puts 'Start searching for these'
end

def result_communication(ok_var, object_types)
  ok_var = ok_var.flatten.uniq
  PrettyConsole.say_in_yellow ("Following #{object_types} are not used in more than one file:")
  PrettyConsole.say_in_yellow (ok_var)
  puts "=> #{(ok_var).count} unused #{object_types} names"
end

# -----------------------------------------------------------------------------

namespace :diet do
  desc 'check single use of css variable references'
  task fast_css_variables: :environment do
    var_names = []
    valid_file_extension_list = ['.css', '.scss', '.js', '.jsx', '.slim', '.erb', '.rb', '.html', '.text']

    search_in_css_files do |line|
      if line.match?(/\s*(\$.*):/)
        var_names += line.scan(/(\$[[a-z]-_]*[^:])/).flatten
      end
    end
    communication_over_objects_to_find(var_names.count, "variables")

    valid_file_extension_list = ['.css', '.scss', '.js', '.jsx', '.slim', '.erb', '.rb', '.html', '.text']
    search_domain = [ Rails.root.join('app'),
                  Rails.root.join('lib'),
                  Rails.root.join('test') ]
    ok_var = search_in_files(var_names.uniq, search_domain, valid_file_extension_list)

    result_communication(ok_var, "variables")
  end

  desc 'check single use of css classes references'
  task fast_css_classes: :environment do
    class_names = []

    search_in_css_files do |line|
      captures = line.match(/\s*\.([a-z0-9_-]*)|[^.]/).captures
      captures -= ['.'] if captures.include?('.')
      class_names += captures
    end
    class_names = class_names.compact.uniq

    communication_over_objects_to_find(class_names.count, "classes")

    valid_file_extension_list = ['.css', '.scss', '.js', '.jsx', '.slim', '.erb', '.rb', '.html', '.text']
    search_domain = [ Rails.root.join('app'),
                  Rails.root.join('lib'),
                  Rails.root.join('test') ]
    ok_var = search_in_files(class_names.uniq, search_domain, valid_file_extension_list)

    result_communication(ok_var, "classes")
    puts "Be careful about classes used in third party code, like iframes for video players"
  end

  desc 'check single use of ruby classes references'
  task fast_ruby_methods: :environment do
    method_names = []

    search_in_ruby_files do |line|
      captures = line.match(/^\s*def\s+(?:self\.)?([a-z0-9_]+\??)\s*|[^(].*$/).captures
      captures -= ['.'] if captures.include?('.')
      method_names += captures
    end
    method_names = method_names.compact.uniq

    communication_over_objects_to_find(method_names.count, "methods")

    valid_file_extension_list = ['.slim', '.html', '.text', '.erb', '.rb', '.rake']
    search_domain = [
      Rails.root.join('app'),
      Rails.root.join('config'),
      Rails.root.join('db'),
      Rails.root.join('lib'),
      Rails.root.join('test') ]
    ok_var = search_in_files(method_names, search_domain, valid_file_extension_list)

    result_communication(ok_var, "methods")
    PrettyConsole.say_with_white_background( "Be careful not to get rid of overwritting gems methods. " )
    PrettyConsole.say_with_white_background( "Define_method uses should be checked as well !" )
  end
end