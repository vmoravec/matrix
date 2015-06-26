# Gates are available only through SSH key based auth beside localhost
namespace :gate do
  desc "Image for admin node prepared"
  task :prepare_admin do
    gate.prepare_admin
  end
end
