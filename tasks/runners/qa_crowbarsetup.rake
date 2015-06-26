namespace :qa_crowbarsetup do
  desc "Crowbar installation prepared"
  task :prepareinstallcrowbar do
    qa_crowbarsetup.exec! "prepareinstallcrowbar"
  end

  desc "Crowbar installed"
  task :installcrowbar do
    qa_crowbarsetup.exec! "installcrowbar"
  end

  desc "Nodes allocated"
  task :allocate do
    qa_crowbarsetup.exec! "allocate"
  end

  desc "Standalone node(s) registered with crowbar"
  task :crowbar_register do
    qa_crowbarsetup.exec! "crowbar_register"
  end

  desc "A single proposal installed"
  task :do_one_proposal do
    qa_crowbarsetup.exec! "do_one_proposal nova", admin_runlist: false
  end

end
