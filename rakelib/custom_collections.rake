namespace :test do
  desc 'GET request for ellie.com custom collections'
  task :custom_collections do
      CUSTOMCOLLECTION.pull
  end
end
