namespace :qa_crowbarsetup do
  desc "Prepare admin node for crowbar installation"
  task :prepareinstallcrowbar do
    qa_crowbarsetup.exec! "prepareinstallcrowbar"
  end

  desc "Install crowbar"
  task :installcrowbar do
    qa_crowbarsetup.exec! "installcrowbar"
  end

  desc "Allocate nodes"
  task :allocate do
    qa_crowbarsetup.exec! "allocate"
  end

end
