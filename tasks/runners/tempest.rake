namespace :tempest do
  desc "Tempest tests run"
  task :run do
    tempest.run
  end
end
