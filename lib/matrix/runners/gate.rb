module Matrix
  class Gate < Runner

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

  end
end
