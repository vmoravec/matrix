# Gates are available only through SSH key based auth
namespace :gate do
  desc "Prepare libvirt domain for crowbar"
  task :prepare_admin do
    story.begin do |story|
      libvirt_domain = story.target.gate.admin_domain.name
      snapshot_source = "/var/lib/libvirt/images/#{libvirt_domain}.raw.snapshot-base_install"
      snapshot_destination = "/var/lib/libvirt/images/#{libvirt_domain}.raw"
      gate.exec! "virsh destroy #{libvirt_domain}"
      gate.exec! "cp #{snapshot_source} #{snapshot_destination}"
      gate.exec! "virsh start #{libvirt_domain}"
    end
  end
end
