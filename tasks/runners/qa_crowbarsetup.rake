namespace :qa_crowbarsetup do
  desc "Run any custom command; provide command=COMMAND"
  task :run do
    qa_crowbarsetup.exec! ENV["command"]
  end

  desc "Crowbar installation prepared"
  task :prepareinstallcrowbar do
    qa_crowbarsetup.exec! "prepareinstallcrowbar", onadmin: true
  end

  desc "Crowbar installed"
  task :installcrowbar do
    qa_crowbarsetup.exec! "installcrowbar", onadmin: true
  end

  desc "Standalone node(s) registered with crowbar"
  task :crowbar_register do
    qa_crowbarsetup.exec! "crowbar_register"
  end

  desc "Role and platform for nodes set"
  task :configure_nodes do
    qa_crowbarsetup.configure_nodes
  end

  desc "Update repo added"
  task :addupdaterepo do
    qa_crowbarsetup.exec! "addupdaterepo", onadmin: true
  end

  desc "Update run"
  task :runupdate do
    qa_crowbarsetup.exec! "runupdate", onadmin: true
  end

  desc "Allocate nodes"
  task :allocate do
    qa_crowbarsetup.exec! "allocate", onadmin: true
  end

  desc "All nodes rebooted"
  task :rebootnodes do
    qa_crowbarsetup.reboot_nodes
  end

  desc "Nodes installed and ready"
  task :waitcloud do
    qa_crowbarsetup.exec! "waitcloud", onadmin: true
  end

  desc "Nodes prepared for proposals' installation"
  task :prepare_proposals do
    qa_crowbarsetup.exec! "prepare_proposals"
  end

  desc "Dashboard alias set"
  task :set_dashboard_alias do
    qa_crowbarsetup.exec! "set_dashboard_alias"
  end

  desc "Testsetup done"
  task :testsetup do
    qa_crowbarsetup.exec! "testsetup", onadmin: true
  end

  desc "Deploy all proposals automatically by mkcloud"
  task :proposal do
    qa_crowbarsetup.exec! "proposal", onadmin: true
  end

  namespace :proposal do
    @barclamps = %w(
      pacemaker
      database
      rabbitmq
      keystone
      swift
      ceph
      glance
      cinder
      neutron
      nova
      horizon
      ceilometer
      heat
      manila
      trove
      tempest
    )

    @barclamps.each do |barclamp|
      desc "Barclamp #{barclamp} deployed"
      task barclamp do
        qa_crowbarsetup.exec! "deploy_single_proposal #{barclamp}"
      end
    end
  end

end
