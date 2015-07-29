namespace :qa_crowbarsetup do
  desc "Run any custom command; provide command=COMMAND"
  task :run do
    qa_crowbarsetup.exec! ENV["command"]
  end

  desc "Crowbar installation prepared"
  task :prepareinstallcrowbar do
    qa_crowbarsetup.exec! "prepareinstallcrowbar"
  end

  desc "Crowbar installed"
  task :installcrowbar do
    qa_crowbarsetup.exec! "installcrowbar"
  end

  desc "Standalone node(s) registered with crowbar"
  task :crowbar_register do
    qa_crowbarsetup.exec! "crowbar_register"
  end

  desc "Role and platform for nodes set"
  task :configure_nodes do
    qa_crowbarsetup.configure_nodes
  end

  desc "All nodes rebooted"
  task :reboot do
    qa_crowbarsetup.reboot
  end

  desc "Nodes installed and ready"
  task :waitcompute do
    qa_crowbarsetup.exec! "waitcloud"
  end

  desc "Nodes prepared for proposals' installation"
  task :prepare_proposals do
    qa_crowbarsetup.exec! "prepare_proposals", admin_runlist: false
  end

  desc "Dashboard alias set"
  task :set_dashboard_alias do
    qa_crowbarsetup.exec! "set_dashboard_alias", admin_runlist: false
  end

  desc "Testsetup done"
  task :testsetup do
    qa_crowbarsetup.exec! "testsetup"
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
      nova_dashboard
      ceilometer
      heat
      trove
      tempest
    )

    @barclamps.each do |barclamp|
      desc "Barclamp #{barclamp} deployed"
      task barclamp do
        qa_crowbarsetup.exec! "deploy_single_proposal #{barclamp}", admin_runlist: false
      end
    end
  end

end
