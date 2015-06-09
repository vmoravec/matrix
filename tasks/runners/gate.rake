# Gates are available only through SSH key based auth
namespace :gate do
  desc "Prepare libvirt domain for crowbar"
  task :prepare_admin do
    gate.exec! "ls"
  end
end
