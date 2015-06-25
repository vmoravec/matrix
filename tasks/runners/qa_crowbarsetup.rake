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

  desc "Register nodes with crowbar_register"
  task :crowbar_register do
    qa_crowbarsetup.exec! "crowbar_register"
  end

end
