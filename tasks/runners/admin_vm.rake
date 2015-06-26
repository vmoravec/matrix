namespace :admin_vm do
  desc "Admin libvirt domain prepared"
  task :prepare do
    admin_vm.prepare
  end
end
