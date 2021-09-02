namespace :db do
  namespace :structure do
    # heroku hack for review apps
    task dump: [:environment, :load_config] do
      rewrite_comment_on_extension
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
  end
end
