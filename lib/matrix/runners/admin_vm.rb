module Matrix
  class AdminVmRunner < Runner
    def initialize
      super do
        @command = RemoteCommand.new(
          ip: gate.admin_vm.domain,
          user: gate.admin_vm.user,
          timeout: 30,
          proxy: {
          "user" => gate.user,
          "fqdn" => gate.fqdn || gate.ip,
          }
        )
      end
    end

    def prepare
      attempts = 1
      begin
        command.test_ssh!
      rescue
        attempts += 1
        sleep 5
        retry unless attempts == 5
      end

      exec! "rm -f qa_crowbarsetup.sh"
      repo_config = Matrix.config["git"]["automation"]
      repo_url = repo_config["url"].gsub!(":", "/")
      exec! "wget --no-check-certificate " +
            "https://raw.#{repo_url}/#{repo_config["branch"]}/scripts/qa_crowbarsetup.sh"
    end
  end
end
