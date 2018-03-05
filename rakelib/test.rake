namespace :test do
  desc 'GET request for ellie.com products + variants'
  task :subs do
      EMAIL.generate
  end
  task :send do
      EMAIL.send
  end
end
