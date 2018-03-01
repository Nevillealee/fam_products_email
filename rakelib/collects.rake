namespace :test do
  desc 'GET request for ellie.com collects'
  task :collects do
      COLLECT.pull
  end
end
