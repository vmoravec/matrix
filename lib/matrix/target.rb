module Matrix
  class Targets
    extend Forwardable

    def_delegators :@targets, :map, :include?

    attr_reader :targets

    def initialize config
      @targets = config["targets"].keys.map do |name|
        Target.new(name, config["targets"][name])
      end
    end

    def find target_name
      targets.find {|t| t.name == target_name.to_s }
    end

    def all
      show(targets)
    end

    def only *target_names
      selected = target_names.flatten.map do |target|
        find(target)
      end.flatten
      show(selected)
    end

    private

    def show targets
      targets.map do |target|
        length = 10 - target.name.length
        "#{target.name}" + " "*length + "# #{target.desc}"
      end.join("\n")
    end
  end

  class Target
    attr_reader :name, :desc, :gate, :admin_node, :control_node

    def initialize name, options
      @name = name
      @desc = options["desc"]
      @gate = Gate.new(options["gate"])
      @admin_node = AdminNode.new(options)
      @control_node = OpenStruct.new(options["control_node"])
    end

    class Gate
      attr_reader :ip, :fqdn, :user, :admin_domain, :command

      def initialize params
        @ip = params["ip"]
        @fqdn = params["fqdn"]
        @user = params["user"]
        return unless params["admin_domain"]

        @admin_domain = OpenStruct.new(
          name: params["admin_domain"]["name"],
          user: params["admin_domain"]["user"]
        )
      end

      def localhost?
        fqdn == "localhost"
      end

    end

    def inspect
      <<output
Description: #{desc}
Gate:
  Fqdn:  #{gate.fqdn}
  User:  #{gate.user}
  Admin domain:  #{gate.admin_domain.name if gate.admin_domain}
Admin node:
  Ip:  #{admin_node.ip}
  Fqdn:  #{admin_node.fqdn}
  User:  #{admin_node.user}
  Password:  #{admin_node.password || '(unspecified)'}
output
    end

  end
end
