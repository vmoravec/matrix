module Matrix
  class QaCrowbarSetupRunner < Runner
    COMMAND = "qa_crowbarsetup.sh"

    def initialize
      super do
        if gate.localhost?
          raise "#{COMMAND} is not intended to run on localhost"
        end

        @command =
          RemoteCommand.new(
            ip: gate.admin_vm.name,
            user: gate.admin_vm.user,
            proxy: {
              "user" => gate.user,
              "fqdn" => gate.fqdn
            },
            capture: false
          )
      end
    end

    def exec! action, admin_runlist: true
      @environment = config["mkcloud"].inject("") do |env, config_pair|
        key, value = config_pair
        value.to_s.empty? ? env : env << "#{key}=#{value} "
      end
      bin = "/root/#{COMMAND}"
      prepare = "source #{bin}; #{'onadmin_runlist' if admin_runlist} "
      super(prepare << action.to_s)
    end
  end
end
