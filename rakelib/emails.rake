namespace :email do
  desc 'Send email of csv for inventory report'
  task :send do
      EMAIL.send
  end
end
