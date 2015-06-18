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
      libvirt_domain = story.target.gate.admin_domain.name
      snapshot_source = "/var/lib/libvirt/images/#{libvirt_domain}.raw.snapshot-base_install"
      snapshot_destination = "/var/lib/libvirt/images/#{libvirt_domain}.raw"
      domain_exists = exec!("virsh list | grep #{libvirt_domain}") rescue nil
      exec! "virsh destroy #{libvirt_domain}" if domain_exists
      exec! "cp #{snapshot_source} #{snapshot_destination}"
      exec! "virsh start #{libvirt_domain}"
    end

  end
end
