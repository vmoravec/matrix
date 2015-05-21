module Matrix
  class AdminNode
    attr_reader :ip, :user, :password

    def initialize options
      @ip = options["ip"]
      @user = options["user"]
      @password = options["password"]
      @fqdn = options["fqdn"]
    end
  end
end
