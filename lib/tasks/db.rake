namespace :db do
  namespace :structure do
    # heroku hack for review apps
    task dump: [:environment, :load_config] do
      filename = ENV["SCHEMA"] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")

      sql_default = File.read(filename)
                        .each_line
                        .grep_v(/\ACOMMENT ON EXTENSION.+/) # see: https://www.thinbug.com/q/44168957
                        .join
      File.write(filename, sql_default)

      filename_review = ENV["SCHEMA"] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure-review.sql")
      sql_structure_review = File.read(filename)
                                 .each_line
                                 .map{|str| str.gsub(/thesaurus_monstage/, 'thesaurus_astro')  } # avoid issue with custom dict on heroku
                                 .join

      File.write(filename_review, sql_structure_review)
    end
  end
end
