namespace :db do
  namespace :structure do
    # heroku hack for review apps
    task dump: [:environment, :load_config] do
      rewrite_comment_on_extension
      change_custom_thesaurus
    end

    # can't comment on extension public extension [heroku]
    def rewrite_comment_on_extension
      filename = ENV["SCHEMA"] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")

      sql = File.read(filename)
                .each_line
                .grep_v(/\ACOMMENT ON EXTENSION.+/) # see: https://www.thinbug.com/q/44168957
                .join

      File.write(filename, sql)
    end

    # custom thesaurus does not works on heroku
    def change_custom_thesaurus
      filename = ENV["SCHEMA"] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")
      filename_review = ENV["SCHEMA"] || File.join(Rails.root, 'infra', 'review', "structure-review.sql")

      custom_thesaurus = <<~SQL
        CREATE TEXT SEARCH DICTIONARY public.dict_search_with_synonoym (
          TEMPLATE = pg_catalog.snowball,
          language = 'french');
      SQL
      thesaurus_matcher = /^CREATE TEXT SEARCH DICTIONARY public.dict_search_with_synonoym \(.*?\)\;$/m
      sql_structure_review = File.read(filename)
                                 .gsub(thesaurus_matcher,
                                       custom_thesaurus)
      File.write(filename_review, sql_structure_review)
    end
  end
end
