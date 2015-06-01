module Matrix
  class Targets
    extend Forwardable

    def_delegators :@targets, :map

    attr_reader :targets

    def initialize config
      @targets = config["targets"].keys.map do |name|
        Target.new(name, config["targets"][name])
      end
    end

    def find target_name
      targets.find {|t| t.name == target_name.to_s }
    end

    def list
      targets.map do |target|
        length = 10 - target.name.length
        "#{target.name}" + " "*length + "# #{target.desc}"
      end.join("\n")
    end
  end

  class Target
    attr_reader :name, :desc, :gate, :admin_node

    def initialize name, options
      @name = name
      @desc = options["desc"]
      @gate = Gate.new(options["gate"]) if options["gate"]
      @admin_node = AdminNode.new(options.merge("gate" => gate))
    end

    def verify!
      gate.verify!
    end

    class Gate
      attr_reader :ip, :fqdn, :user, :password, :domain, :command

      def initialize params
        @gate = params["gate"]
        @ip = params["ip"]
        @fqdn = params["fqdn"]
        @user = params["user"]
        @password = params["password"]
        @domain = params["admin_domain"]
        @command = RemoteCommand.new(
          ip: ip || fqdn, user: user, password: password
        )
      end

      def exec! *params
        command.exec!(*params)
      end

    end

    def inspect
      if gate
      <<output
Description: #{desc}
Gate:
  Fqdn:     #{gate.fqdn}
  User:     #{gate.user}
  Domain:   #{gate.domain}
Admin node:
  Ip:       #{admin_node.ip}
  Fqdn:     #{admin_node.fqdn}
  User:     #{admin_node.user}
  Password: #{admin_node.password || '(none)'}
output
      else
        <<output
Description: #{desc}
Admin node:
  Ip:       #{admin_node.ip}
  Fqdn:     #{admin_node.fqdn}
  User:     #{admin_node.user}
  Password: #{admin_node.password || '(none)'}
output
      end
    end

  end
end
