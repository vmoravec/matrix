module Matrix
  class CrowbarRunner < Runner
    attr_reader :proposals, :nodes

    def initialize
      super do
        @command = story.current_target.admin_node.command
      end
      @proposals = story.config["proposals"] || []
      @nodes = story.config["nodes"] || {}
    end

    def list_machines
      exec!("crowbar machines list").output
    end

    def list_nodes
      list_machines.split.map(&:strip).grep(/\Ad/)
    end

    def network_proposal
      proposal = exec!("crowbar network proposal show default").output
      networks = JSON.parse(proposal)["attributes"]["network"]["networks"]
      puts ranges = networks["bmc"]["ranges"]
    end

    def allocate
      list_nodes.each do |machine|
        exec!("crowbar machines allocate #{machine}")
        sleep 5
        node_alias = machine.match(/-(\w+)\./).captures.first
        exec!("cat >> .ssh/config<<EOF\nHost node #{node_alias}\nHostName #{machine}\nEOF")
      end
    end

    def wait_all_discovered
      wait_for "All nodes are visible", max: "5 minutes", sleep: "10 seconds" do
        break if list_nodes.size == nodes.keys.size
      end

      discovered = "discovered"
      wait_for "All nodes are discovered", max: "5 minutes", sleep: "10 seconds" do
        nodes_states = list_nodes.map do |node|
          exec!("knife node show -a state #{node}").output.match(discovered).to_s
        end
        break if nodes_states.select {|n| n == discovered }.size == nodes.keys.size
      end
    end

    def batch build: nil, export: nil
      build_proposal(build)
      export_proposal(export)
    end

    def build_proposal name
      return if name.nil?
      proposal = find_proposal(name)
      return unless proposal

      deploy_proposal = { "proposals" => [] }
      deploy_proposal["proposals"] << proposal
      file = exec!("mktemp").output.strip
      exec!("cat > #{file}<<EOF\n#{deploy_proposal.to_yaml}\nEOF")
      exec!("crowbar batch build #{file}")
    end

    def export_proposal name
      return if name.nil?
    end

    private

    def find_proposal proposal
      return unless proposals

      proposals.find {|p| p["barclamp"] == proposal.to_s }
    end
  end
end
