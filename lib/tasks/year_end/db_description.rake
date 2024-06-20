require 'pretty_console'

namespace :year_end do
  desc 'describe column size after exploitation'
  task :column_size, [] => :environment do |args|
    tables = [InternshipOffer,
              Organisation,
              InternshipOfferInfo,
              InternshipApplication,
              InternshipAgreement]
    table_list = tables.map do |table| table.name end.join(', ')
    PrettyConsole.announce_task("Describing column size for #{table_list}") do
      tables.each do |table|
        PrettyConsole.puts_in_green "Table: #{table.name}"
        puts '=================='
        
        table.column_names.each do |column_name|
          next unless table.columns_hash[column_name].type == :string
          limit = table.pluck(column_name.to_sym)
                       .map(&:to_s)
                       .map(&:strip)
                       .sort_by { |a| a.to_s.size}
                       .last
                       .size
          PrettyConsole.print_in_yellow "#{table.name}##{column_name} limit: #{limit}"
          puts ''
        end
        puts '-------------------'
        puts ' '
      end
    end
  end
end