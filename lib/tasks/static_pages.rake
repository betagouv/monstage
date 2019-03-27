namespace :static_pages do
  desc "Build static pages"
  task :build do
    sh "jekyll b --config config/jekyll.yml"
  end
end
