namespace :test do
  desc 'GET request for ellie.com products + variants'
  task :products do
      PRODUCT.pull
  end
end
