namespace :tempest do
  desc "Set up and run tempest tests"
  task :run do
    tempest.run
  end
end
