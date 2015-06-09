module Matrix
  class AdminNode
    attr_reader :ip, :user, :password, :fqdn, :command, :api

    def initialize options
      config = options["admin_node"]
      ssh = config["ssh"]
      @user = ssh["user"]
      @password = ssh["password"]
      @api = config["api"]
      @ip = config["ip"]
      @fqdn = config["fqdn"]
      @command = RemoteCommand.new(
        ip: ip || fqdn, user: user, password: password
      )
    end

    def exec! *params
      command.exec!(*params)
    end

    def credentials
      {
        "ip"   => ip,
        "fqdn" => fqdn,
        "api"  => api,
        "ssh"  => {
          "user"     => user,
          "password" => password
        }
      }
    end

  end
end
