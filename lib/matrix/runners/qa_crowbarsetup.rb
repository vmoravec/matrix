module Matrix
  class QaCrowbarSetupRunner < Runner
    COMMAND = "qa_crowbarsetup.sh"
    DEFAULT_PLATFORM = "suse-12.0"

    def initialize
      super do
        if gate.localhost?
          raise "#{COMMAND} is not intended to run on localhost"
        end

        @command =
          RemoteCommand.new(
            ip: gate.admin_vm.name,
            user: gate.admin_vm.user,
            proxy: {
              "user" => gate.user,
              "fqdn" => gate.fqdn
            },
            capture: false
          )
      end
    end

    def exec! action, onadmin: false
      action.prepend("onadmin_") if onadmin
      @environment = config["mkcloud"].inject("") do |env, config_pair|
        key, value = config_pair
        value.to_s.empty? ? env : env << "export #{key}=#{value}; "
      end
      super(action.to_s.prepend("source /root/#{COMMAND}; "))
    end

    def configure_nodes
      crowbar = CrowbarRunner.new
      nodes = config["nodes"] || {}
      configured_nodes = nodes.keys

      crowbar.list_nodes.each do |node|
        node = node.strip
        next unless nodes[node]

        role = nodes[node]["role"] || "compute"
        platform = nodes[node]["platform"] || DEFAULT_PLATFORM
        exec!( "set_node_role_and_platform #{node} #{role} #{platform}")
      end
    end

    def reboot_nodes
      if story.target.name == "qa1"
        command.exec!("curl http://clouddata.cloud.suse.de/git/automation/scripts/qa1_nodes_reboot | bash")
      else
        exec!("reboot_nodes_via_ipmi")
        sleep 150
      end
    end
  end
end
