namespace :tempest do
  desc "Run tempest tests"
  task :run do
    tempest.run
  end
end
