namespace :mkcloud do
  desc "Cleanup leftovers from last run"
  task :cleanup do
    mkcloud.exec! :cleanup
  end

  desc "Prepare the environment for cloud installation"
  task :prepare do
    mkcloud.exec! :prepare
  end

  desc "Setup admin node"
  task :setupadmin do
    mkcloud.exec! :setupadmin
  end

  desc "Install crowbar"
  task :installcrowbar do
    mkcloud.exec! "addupdaterepo runupdate prepareinstcrowbar instcrowbar"
  end

  desc "Set up & install controller and compute nodes"
  task :installnodes do
    mkcloud.exec! "setupnodes instnodes"
  end

  desc "Install default proposal"
  task :installproposal do
    mkcloud.exec! "proposal"
  end

  desc "Set up and run tempest"
  task :testsetup do
    mkcloud.exec! "testsetup"
  end

  desc "Show the full path to mkcloud script"
  task :bin do
    mkcloud.bin
  end
end
