web: bundle exec puma -C config/puma.rb
worker: QUEUES=default,batches,mailers bundle exec rails jobs:work
