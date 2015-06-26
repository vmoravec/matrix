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
    mkcloud.exec! "addupdaterepo runupdate prepareinstcrowbar instcrowbar"
  end

  desc "Nodes installed"
  task :installnodes do
    mkcloud.exec! "setupnodes instnodes"
  end

  desc "Controller node and compute node installed"
  task :installproposal do
    mkcloud.exec! "proposal"
  end

  desc "Show the full path to mkcloud script"
  task :bin do
    mkcloud.bin
  end
end
