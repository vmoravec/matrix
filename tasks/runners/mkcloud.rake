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
    mkcloud.exec! "setupcompute instcompute"
  end

  desc "Install default proposal"
  task :installproposal do
    mkcloud.exec! "proposal"
  end

  desc "Show the full path to mkcloud script"
  task :binpath do
    mkcloud.binpath
  end
end
