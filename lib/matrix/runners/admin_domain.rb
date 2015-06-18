module Matrix
  class AdminDomainRunner < Runner
    def initialize
      super do
        @command = RemoteCommand.new(
          ip: gate.admin_domain.name,
          user: gate.admin_domain.user,
          timeout: 30,
          proxy: {
          "user" => gate.user,
          "fqdn" => gate.fqdn || gate.ip,
          }
        )
      end
    end
  end
end
