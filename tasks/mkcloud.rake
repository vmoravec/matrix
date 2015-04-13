namespace :mkcloud do
  desc "Cleanup leftovers from last run"
  task :cleanup, :env do |_, env|
    mkcloud.exec! :cleanup, env
  end

  desc "Prepare the environment for cloud installation"
  task :prepare do |config|
    puts config
    mkcloud.exec :prepare
  end
end
