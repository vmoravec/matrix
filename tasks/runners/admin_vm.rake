namespace :admin_vm do
  desc "Prepare admin domain for crowbar setup"
  task :prepare do
    admin_vm.prepare
  end
end
