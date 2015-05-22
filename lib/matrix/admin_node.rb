module Matrix
  class AdminNode
    attr_reader :ip, :user, :password, :fqdn, :command

    def initialize options
      @ip = options["ip"]
      @user = options["user"]
      @password = options["password"]
      @fqdn = options["fqdn"]
      @command = RemoteCommand.new(
        ip: ip || fqdn, user: user, password: password
      )
    end

    def exec! *params
      command.exec!(*params)
    end

  end
end
