# Gates are available only through SSH key based auth beside localhost
namespace :gate do
  desc "Prepare libvirt domain for crowbar"
  task :prepare_admin do
    gate.prepare_admin
  end
end
