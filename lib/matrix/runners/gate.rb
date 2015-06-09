module Matrix
  class Gate < Runner
    include Utils::User

    attr_reader :gate

    def initialize
      super do
        @gate = story.current_target.gate
        @command = RemoteCommand.new(
          ip: gate.ip || gate.fqdn,
          user: gate.user
        )
      end
    end

  end
end
