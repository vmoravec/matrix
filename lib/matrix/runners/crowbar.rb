module Matrix
  class CrowbarRunner < Runner
    attr_reader :proposals

    def initialize
      super do
        @command = story.current_target.admin_node.command
      end
      @proposals = story.config["proposals"]
    end

    def batch build: [], export: []
      props =
        case build
        when Symbol then [ build ]
        when Array  then build
        else raise "Symbol or array allowed for proposal builds"
        end

      abort "No proposals found" if props.empty?
      detect_proposals(props)
      props.each do |proposal|
        prop = find_proposal(proposal)
        deploy_proposal = { "proposals" => [] }
        deploy_proposal["proposals"] << prop
        file = exec!("mktemp").output
        exec!("cat > #{file}<<EOF\n \"#{deploy_proposal.to_yaml}\"\nEOF")
        exec!("crowbar batch build #{file}")
      end
    end

    private

    def use_tempfile content
      file = exec!("mktemp").output
      exec!("cat > #{file}<<EOF\n \"#{content.to_yaml}\"\nEOF")
      yield file
    end

    def detect_proposals props
      props.each do |proposal|
        if !find_proposal(proposal)
          abort "Proposal #{proposal} not found"
        end
      end
    end

    def find_proposal proposal
      return unless proposals

      proposals.find {|p| p["barclamp"] == proposal.to_s }
    end
  end
end
