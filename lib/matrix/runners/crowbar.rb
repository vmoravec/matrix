module Matrix
  class CrowbarRunner < Runner
    attr_reader :proposals

    def initialize
      super do
        @command = story.current_target.admin_node.command
      end
      @proposals = story.config["proposals"]
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
