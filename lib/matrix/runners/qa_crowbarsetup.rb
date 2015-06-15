module Matrix
  class QaCrowbarSetup < Runner
    COMMAND = "qa_crowbarsetup.sh"

    def initialize
      super do
        if gate.localhost?
          raise "#{COMMAND} is not intended to run on localhost"
        end

        @command =
          RemoteCommand.new(
            ip: gate.admin_domain.name,
            user: gate.admin_domain.user,
            proxy: {
              "user" => gate.user,
              "fqdn" => gate.fqdn
            }
          )
      end
    end

    def exec! action
      bin = "/root/#{COMMAND}"
      prepare = "source #{bin}; onadmin_runlist "
      super(prepare << action.to_s)
    end
  end
end
