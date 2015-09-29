module Matrix
  class GateRunner < Runner

    def initialize
      super do
        @command =
          if gate.localhost?
            LocalCommand.new
          else
            RemoteCommand.new(
              ip: gate.ip || gate.fqdn,
              user: gate.user
            )
          end
      end
    end

    def prepare_admin
      case story.target.name
      when "qa2", "qa3"
        libvirt_domain = story.target.gate.admin_vm.name
        snapshot_source = "/var/lib/libvirt/images/backup/#{libvirt_domain}.raw"
        snapshot_destination = "/var/lib/libvirt/images/#{libvirt_domain}.raw"
        domain_exists = exec!("virsh list | grep #{libvirt_domain}") rescue nil
        exec! "virsh destroy #{libvirt_domain}" if domain_exists
        exec! "cp #{snapshot_source} #{snapshot_destination}"
        exec! "virsh start #{libvirt_domain}"
      when "qa1"
        vm_name = story.target.gate.admin_vm.name
        exec! "virsh destroy #{vm_name}"
        exec! "virsh snapshot-revert #{vm_name} base_install2 --running"
        exec! "virsh start #{vm_name}"
      else
        abort "Don't know how to prepare admin for target '#{story.target.name}'"
      end
    end

  end
end
