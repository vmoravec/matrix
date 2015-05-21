module Matrix
  class Target
    attr_reader :name

    def initialize name, options
      @name = name
      @gate = Gate.new(options["gate"]) if options["gate"]
      @admin_node = AdminNode.new(options["admin_node"])
    end

    class Gate
      attr_reader :ip, :fqdn, :user, :password

      def initialize params
        @ip = params["ip"]
        @fqdn = params["fqdn"]
        @user = params["user"]
        @password = params["password"]
        @admin_domain = params["admin_domain"]
      end
    end

  end
end
