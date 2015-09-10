namespace :mkcloud do
  desc "Ancient cloud build wiped out"
  task :cleanup do
    mkcloud.cleanup
  end

  desc "Environment prepared for mkcloud"
  task :prepare do
    mkcloud.exec! :prepare
  end

  desc "Admin node prepared for crowbar installation"
  task :setupadmin do
    mkcloud.exec! :setupadmin
  end

  desc "Admin node installed"
  task :installcrowbar do
    mkcloud.exec! "prepareinstcrowbar instcrowbar"
  end

  desc "Update repos installed"
  task :addupdates do
    mkcloud.exec! "addupdaterepo runupdate"
  end

  desc "Nodes installed"
  task :instnodes do
    mkcloud.exec! "setupnodes instnodes"
  end

  desc "Controller node and compute node installed, barclamps deployed"
  task :proposals do
    mkcloud.exec! "proposal"
  end

  desc "Show the full path to mkcloud script"
  task :bin do
    mkcloud.bin
  end

  desc "Run custom mkcloud command; use: command=COMMAND"
  task :run do
    mkcloud.exec! ENV["command"]
  end

  desc "Run cct tests"
  task :cct do
    mkcloud.exec! "cct"
  end
end
