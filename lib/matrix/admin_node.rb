module Matrix
  class AdminNode
    attr_reader :ip, :user, :password, :fqdn, :command

    def initialize options
      config = options["admin_node"]
      @ip = config["ip"]
      @fqdn = config["fqdn"]
      @user = config["user"]
      @password = config["password"]
      @command = RemoteCommand.new(
        ip: ip || fqdn, user: user, password: password
      )
    end

    def exec! *params
      command.exec!(*params)
    end

  end
end
